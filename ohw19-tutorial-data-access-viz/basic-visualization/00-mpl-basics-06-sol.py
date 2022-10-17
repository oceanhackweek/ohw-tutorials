import iris
import matplotlib.pyplot as plt

import numpy.ma as ma
import cartopy.crs as ccrs
from cartopy.io import shapereader
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER

from ciso import zslice


def make_map(projection=ccrs.PlateCarree()):
    fig, ax = plt.subplots(figsize=(9, 13),
                           subplot_kw=dict(projection=projection))
    gl = ax.gridlines(draw_labels=True)
    gl.xlabels_top = gl.ylabels_right = False
    gl.xformatter = LONGITUDE_FORMATTER
    gl.yformatter = LATITUDE_FORMATTER
    ax.coastlines('50m')
    return fig, ax



cube = iris.load_cube(url, "sea_water_potential_temperature")
cube = cube[-1, ...]  # last time step

lon = cube.coord(axis='X').points
lat = cube.coord(axis='Y').points
p = cube.coord("sea_surface_height_above_reference_ellipsoid").points
p0 = -250
isoslice = zslice(cube.data, p, p0)

fig, ax = make_map()
ax.set_extent(
    [lon.min(), lon.max(),
     lat.min(), lat.max()]
)

cs = ax.pcolormesh(
    lon, lat,
    ma.masked_invalid(isoslice),
)

kw = {"shrink": 0.65, "orientation": "horizontal", "extend": "both"}
cbar = fig.colorbar(cs, **kw)
