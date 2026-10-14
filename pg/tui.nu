export def main  [
	--auth: record<host:string, port:int, user:string, password:string, database: string>,
] {
	let auth = (
		$auth
		| default { $env.pg?.auth? }
		| default { error make {msg: "no auth detected. either offer one directly or load it into the env" } }
	);

	( ^rainfrog
		--driver "postgres"
		--host $auth.host
		--port $auth.port
		--database $auth.database
		--username $auth.user
		--password $auth.password
	)
}
