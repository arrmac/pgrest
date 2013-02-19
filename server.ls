require! {express, optimist, plv8x}
conString = process.argv.2 or process.env.PGRESTCONN or process.env.TESTDBNAME
port = 3000
app = express!

plx <- (require \./).new conString

rows <- plx.query """
  SELECT t.table_name tbl FROM INFORMATION_SCHEMA.TABLES t WHERE t.table_schema = 'public';
"""
cols = for {tbl} in rows => mount-model tbl

app.get '/collections', (req, res) ->
  res.setHeader 'Content-Type', 'application/json; charset=UTF-8'
  res.end JSON.stringify cols

app.listen port
console.log "Available collections:\n#{ cols * ' ' }"
console.log "Serving `#conString` on http://localhost:#port/collections"

function mount-model (name)
  app.get "/collections/#name", (req, resp) ->
    param = req.query{ l, sk, c, s, q } <<< { collection: name }
    try
      body <- plx.select param
      resp.setHeader 'Content-Type' 'application/json; charset=UTF-8'
      resp.end body
    catch
      return resp.end "error: #e"
  return name