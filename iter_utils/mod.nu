export module except.nu 

export module pipe { 
    export def new [] {
        let source_tag = random int;
        let sink_tag = random int;

        let pipe_job_id = job spawn {
            mut sink = {
                status: disconnected,
                job_id : null
            };

            mut source = {
                status: disconnected,
                job_id : null
            }

            mut request = null;
             
            loop {
                # alias send_sink = job send --tag $sink.tag $sink.job_id;
                # alias send_source = job send --tag $source.tag $source.job_id;

                match {source: $source.status, sink: $sink.status, } { 
                    { sink: "disconnected", source: "disconnected"  } => {
                        match ( job recv ) {
                            {from: "sink", cmd: "connect", job_id: $job_id } => {
                                $sink.job_id = $job_id
                                $sink.status = "connected";

                                {}
                            }
                            {from: "source", cmd: "connect", job_id: $job_id } => {
                                $source.job_id = $job_id
                                $source.status = "connected";
                            }
                        }

                    }
                    { sink: "closed" , source: "disconnected" } => { break; },
                    { sink: "closed" , source: "connected"    } => { break; },
                    { sink: "closed" , source: "closed" }       => { break; },
                }
            }

        };

        {
            source: $sink,

        }
    }

    export def "new source" [data: any]  {
        let tag = random int;

        let source_job = job spawn {
            let send = {|dest| $in | job send $dest --tag $tag} ;
            let recv = {job recv --tag $tag};

            mut status = running;

            for el in $data { 
                let ping = do $recv;
                match $ping { 
                    { cmd: send, dest: $dest} => { 
                        { data: $el } | do $send $dest 
                    },
                    { cmd: stop } => {
                        return; 
                    }
                }
            } 
             
            let ping = do $recv;

            match $ping { 
                { cmd: send, dest: $dest} => { 
                    done | do $send $dest 
                },
                { cmd: stop } => {
                    return; 
                }
            }
        }; 

        return {
            job: $source_job,
            tag: $tag
        }
    }
}
