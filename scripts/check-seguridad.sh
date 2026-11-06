#!/usr/bin/env bash
# Corre como build command de Netlify (ver netlify.toml). No compila ni transforma nada:
# compara el texto de seguridad entre las dos paginas y, si difiere, frena el deploy.
#   1. El bloque entre los marcadores BLOQUE-SEGURIDAD-CANONICO.
#   2. Los 6 pasos del encendido (<ol class="steps"> ... </ol>).
set -u
cd "$(dirname "$0")/.."

A=iniciador-premium/index.html
B=set-parrillero-premium/index.html
INICIO='<!-- INICIO BLOQUE-SEGURIDAD-CANONICO v1'
FIN='<!-- FIN BLOQUE-SEGURIDAD-CANONICO v1 -->'
fallo=0

# Extrae lo que hay entre dos patrones (inclusive) y saca la indentacion.
extraer() { sed -n "\#$2#,\#$3#p" "$1" | sed 's/^[[:space:]]*//'; }

for f in "$A" "$B"; do
  [ -f "$f" ] || { echo "ERROR: no existe $f"; exit 1; }
  for m in "$INICIO" "$FIN"; do
    n=$(grep -cF -- "$m" "$f")
    [ "$n" -eq 1 ] || { echo "ERROR: $f tiene $n veces el marcador: $m (tiene que ser 1)"; fallo=1; }
  done
done
[ "$fallo" -eq 0 ] || exit 1

comparar() {
  local nombre=$1 desde=$2 hasta=$3
  local a b
  a=$(extraer "$A" "$desde" "$hasta"); b=$(extraer "$B" "$desde" "$hasta")
  if [ -z "$a" ] || [ -z "$b" ]; then
    echo "ERROR: no encontre '$nombre' en alguna de las dos paginas"; fallo=1; return
  fi
  if [ "$a" != "$b" ]; then
    echo "ERROR: '$nombre' es distinto entre $A y $B:"
    diff <(printf '%s\n' "$a") <(printf '%s\n' "$b")
    fallo=1
  else
    echo "OK: $nombre identico en las dos paginas"
  fi
}

comparar "bloque de seguridad" "$INICIO" "$FIN"
comparar "pasos del encendido" '<ol class="steps">' '</ol>'

if [ "$fallo" -ne 0 ]; then
  echo "Deploy frenado: corregí las dos paginas para que digan exactamente lo mismo."
  exit 1
fi
