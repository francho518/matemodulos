# Fuentes para los PDF

Los archivos `DejaVuSans.ttf` y `DejaVuSans-Bold.ttf` se usan únicamente para
generar la evaluación imprimible y su solucionario con `pdf-lib`.

- **Fuente:** DejaVu Sans 2.37.
- **Origen:** paquete `dejavu-fonts-ttf` publicado en jsDelivr
  (`https://cdn.jsdelivr.net/npm/dejavu-fonts-ttf@2.37.3/ttf/`).
- **Licencia:** Bitstream Vera Fonts Copyright y DejaVu changes in public
  domain. El texto completo está en [`LICENSE.txt`](LICENSE.txt).

DejaVu Sans se eligió porque incluye los símbolos que necesita la evaluación:
`π`, `θ`, `√`, `≤`, `≥`, `≈`, `²`, `³`, `−`, `·` y `°`, además de las tildes
del español. Las fuentes estándar de `pdf-lib` no cubren todos esos caracteres.
