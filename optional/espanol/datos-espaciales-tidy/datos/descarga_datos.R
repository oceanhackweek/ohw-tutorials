# Descarga de datos
## Usa la libreria ecmwfr
## Instrucciones: https://eliocamp.github.io/espaciales-tidy-tutorial/useR2021/preparacion.html#Cuentas

request <- list(
  format = "netcdf",
  product_type = "monthly_averaged_reanalysis",
  variable = c("sea_ice_cover", "sea_surface_temperature"),
  year = "2021",
  month = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"),
  time = "00:00",
  grid = c(0.5, 0.5),
  dataset_short_name = "reanalysis-era5-single-levels-monthly-means",
  target = "sea_variables.nc"
)

ecmwfr::wf_request(request, path = here::here("datos/"))

