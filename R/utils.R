#| eval: false
fread_key <- function(path) {
  x <- fread(path)
  if (hasName(x, "Id")) {
    setkey(x, Id)
  }
  x
}