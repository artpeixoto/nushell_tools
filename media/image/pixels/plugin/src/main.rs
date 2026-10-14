use std::io::{Cursor, Write};

use image::DynamicImage::ImageRgba16;
use image::{Rgba, RgbaImage};
use nu_plugin::{EngineInterface, Plugin, PluginCommand, SimplePluginCommand};
use nu_plugin::{EvaluatedCall, MsgPackSerializer, serve_plugin};
use nu_protocol::Type::{self, Record};
use nu_protocol::{IntoValue, LabeledError, Signature, Span, Value, record};
use rayon::iter::{IndexedParallelIterator, IntoParallelIterator, ParallelIterator};
use rayon::slice::ParallelSlice;
use tap::Pipe;

struct Pixels;
struct ReadCmd;
struct WriteCmd;

impl Plugin for Pixels {
    fn version(&self) -> String {
        env!("CARGO_PKG_VERSION").into()
    }

    fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
        vec![Box::new(ReadCmd), Box::new(WriteCmd)]
    }
}

impl SimplePluginCommand for ReadCmd {
    type Plugin = Pixels;

    fn name(&self) -> &str {
        "image pixels read"
    }

    fn description(&self) -> &str {
        "Read the pixels of the image"
    }

    fn signature(&self) -> Signature {
        Signature::build(PluginCommand::name(self)).input_output_type(
            Type::record(),
            Type::list(Type::list(Type::list(Type::Float))),
        )
    }

    fn run(
        &self,
        plugin: &Pixels,
        engine: &EngineInterface,
        call: &EvaluatedCall,
        input: &Value,
    ) -> Result<Value, LabeledError> {
        let Some(Ok(binary)) = input.get_data_by_key("content").map(|x| x.into_binary()) else {
            return Err(LabeledError::new("Wrong type"));
        };
        let image = image::load_from_memory(&binary)
            .map_err(|e| LabeledError::new("failed to parse image content"))?
            .into_rgba8();
        let row_size = image.width();
        let values = image
            .par_pixels()
            .chunks(row_size as usize)
            .map(|row| {
                row.into_iter()
                    .map(|p| {
                        p.0.into_iter()
                            .map(|sp| (sp as f32) / (255.0))
                            .map(|sp| Value::float(sp as f64, Span::unknown()))
                            .collect::<Vec<_>>()
                            .pipe(|v| Value::list(v, Span::unknown()))
                    })
                    .collect::<Vec<_>>()
                    .pipe(|v| Value::list(v, Span::unknown()))
            })
            .collect::<Vec<_>>()
            .pipe(|v| Value::list(v, Span::unknown()));

        return Ok(values);
    }
}
impl SimplePluginCommand for WriteCmd {
    type Plugin = Pixels;

    fn name(&self) -> &str {
        "image pixels write"
    }

    fn description(&self) -> &str {
        "convert the pixels to a png image or smth"
    }

    fn signature(&self) -> Signature {
        Signature::build(PluginCommand::name(self)).input_output_type(
            Type::list(Type::list(Type::list(Type::Float))),
            Type::record(),
        )
    }

    fn run(
        &self,
        plugin: &Pixels,
        engine: &EngineInterface,
        call: &EvaluatedCall,
        input: &Value,
    ) -> Result<Value, LabeledError> {
        let rows = input
            .as_list()?
            .into_iter()
            .map(|row| row.as_list()?.pipe(Result::<_,LabeledError>::Ok))
            .collect::<Result<Vec<_>, _>>()?;

        let height = rows.len();
        let width = rows.first().map(|r| r.len()).unwrap_or(0);

        let mut image = RgbaImage::new(width as u32, height as u32);

        for (y, row) in rows.iter().enumerate() {
            for (x, pixel) in row.iter().enumerate() {
                let pixel = pixel
                    .as_list()?
                    .into_iter()
                    .map(|subpixel|
                        Result::<_,LabeledError>::Ok((subpixel.as_float()? * 255.0) as u8)
                    )
                    .collect::<Result<Vec<_>, _>>()?
                    .pipe(|vals| {
                        Result::<_,LabeledError>::Ok(Rgba(
                            vals.as_array()
                            .ok_or(LabeledError::new("wrong number of pixel components"))?
                            .clone(),
                        ))
                    })?;
                image.put_pixel(x as u32, y as u32, pixel);
            }
        }
        let mut buf = Vec::new();

        {
            let mut writer = Cursor::new(&mut buf);
            image
                .write_to(&mut writer, image::ImageFormat::Png)
                .map_err(|x| LabeledError::new("something failed when converting the image"))?;
        }
        return Ok(Value::record(record!{
            "content" => Value::binary(buf, Span::unknown()),
            "metadata" => Value::record(
                record!{
                    "type" => Value::string( "png", Span::unknown() )
                },
                Span::unknown()
            )
        }, Span::unknown()))
    }
}

fn main() {
    serve_plugin(&Pixels {}, MsgPackSerializer)
}
