export module except.nu 

export module pipe { 

    export def new [] {
        let source_tag = random int;
        let sink_tag = random int;
        let pipe_tag = random int;
         

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
            def send [tag: int, dest: int] {
                {msg: $in, meta: {tag: $tag, dest: $dest}} | job send $dest --tag $tag
            } 

            alias recv = job recv;

            loop {
                # alias send_sink = job send --tag $sink.tag $sink.job_id;
                # alias send_source = job send --tag $source.tag $source.job_id;

                match {source: $source.status, sink: $sink.status, } { 
                    { sink: "disconnected", source: "disconnected"  } => {
                        match ( recv ) {
                            { meta: { tag: $tag, from: $peer, }, msg: "connect" } => {
                                if $tag == $sink_tag {
                                    $sink.job_id = $peer;
                                    $sink.status = "connected";
                                    "connected" | send $tag $peer
                                    
                                } else if $tag == $source_tag  {
                                    $source.job_id = $peer
                                    $source.status = "connected";

                                    "connected" | send $tag $peer
                                } else {
                                    {
            
                                    }        
                                }
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
                    { sink: "disconnected" , source: "closed" , } => { break; },
                    { sink: "connected"    , source: "closed" , } => { break; },
                    { sink: "closed" , source: "closed" , }       => { break; },
                }
            }

        };

        {
            source: {
                pipe_job_id: $pipe_job_id,
                tag: $source_tag,
            },
            sink: {
                pipe_job_id: $pipe_job_id,
                tag: $sink_tag,
            }
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
