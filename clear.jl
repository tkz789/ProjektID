rx = r"CREATE TABLE (\w*)"
io = open("file.sql", "r")


while (!eof(io))
  line = readline(io)
  m = match(rx, line)
  if m === nothing
    continue
  else

    println("DROP TABLE IF EXIST $(m.captures[1]) CASCADE;")
  end
end

