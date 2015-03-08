luaw_server_config = {
  server_ip = "0.0.0.0",
  server_port = 7001,
  connect_timeout = 4000,
  read_timeout = 8000,
  write_timeout = 8000
}

luaw_log_config = {
  log_dir = "./logs",
  log_file_basename = "luaw-log",
  log_file_size_limit = 1024*1024,
  log_file_count_limit = 9,
  log_filename_timestamp_format = '%Y%m%d',
  log_lines_buffer_count = 16,
  syslog_server = "127.0.0.1",
  syslog_port = 514,
}

luaw_webapp_config = {
  base_dir = "./webapps"
}
