fig, ax = make_map(projection=ccrs.PlateCarree())

coastline = cfeature.GSHHSFeature(scale='coarse')
ax.add_feature(coastline)
ax.stock_img()

gl = ax.gridlines(draw_labels=True, linestyle='-.')

gl.xlabels_bottom = gl.ylabels_left = False
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER
gl.xlocator = mticker.FixedLocator([-30, -15, 0, 15, 30, 45, 60])

ax.set_extent([-30, 60, -40, 40])

gl.ylabel_style = {'size': 15, 'color': 'red'}
