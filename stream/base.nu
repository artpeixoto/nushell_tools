use ../iter_utils/ * ;
export def "sender" [--file_name: path ] {
	let file_name = $file_name  | default { random chars  };

	mkfifo $file_name;

	let sender_job_id = job spawn {
		( generate forever
		| each {|_| job recv}
		| take until { $in != {control: stop} }
		| each { to jsonl }
		o>> $file_name
		);


	};

	let send  = { wrap value | job send $sender_job_id }
	let close = { {control: "stop"} | job send $sender_job_id }

	return {
		file_name: $file_name,
		sender_job_id: $sender_job_id,
		send: $send,
		stop: $close ,

		_ty: "file_stream_sender",
	}
}

export def "receiver"  [--file_name: path] {
	# let file_name = $file_name  | default { random chars  };
	# 	mkfifo $file_name;

	# 	let sender_job_id = job spawn {
	# 		( generate forever
	# 		| each {|_| job recv}
	# 		| take until { $in not-has value }
	# 		| each {to jsonl}
	# 		o>> $file_name
	# 		);
	# 	};

	# 	let send  = { wrap value | job send $sender_job_id }
	# 	let close = { {control: "stop"} | job send $sender_job_id }
	# 	return {
	# 		file_name: $file_name,
	# 		sender_job_id: $sender_job_id,
	# 		send: $send,
	# 		stop: $close ,

	# 		_ty: "file_stream_sender",
	# 	}
}
