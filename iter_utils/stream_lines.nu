export def "stream lines" [
] { 
    let input = $in; 
    let main_id = job id;
    let tag = random int ; 
    let line_splitter_job = job spawn { 
        $input | lines | each { wrap data | job send $main_id --tag $tag };
        "done" | job send $main_id --tag $tag
    } 
    
    {job recv --tag $tag } | take while {$in has data} | each {$in.data} 
}
   