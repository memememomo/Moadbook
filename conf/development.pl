+{
	'DBI' => [
        'dbi:mysql:moadbook;mysql_socket=/tmp/mysql.sock',
        'user',
        'pass',
        {
            mysql_enable_utf8   => 1,
            RaiseError          => 1,
        },
	],
}
