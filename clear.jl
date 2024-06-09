rx = r"CREATE TABLE \"?(\w*)\"?"
io = open("create.sql", "r")


while (!eof(io))
  line = readline(io)
  m = match(rx, line)
  if m === nothing
    continue
  else

    println("DROP TABLE IF EXISTS $(m.captures[1]) CASCADE;")
  end
end
close(io)

io = open("functions.sql", "r")
rx = r"create or replace function (\w*)\("i
while (!eof(io)) 
  line = readline(io)
  m = match(rx, line)
  if m === nothing
  else
    println("drop function $(m.captures[1]);")
  end
end

close(io)