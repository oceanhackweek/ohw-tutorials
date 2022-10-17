import fiona

fname = path.joinpath('model_grid', 'grid.shp')

schema = {
    'geometry': 'MultiPolygon',
    'properties': {'name': f'str:{len(grid.mesh)}'}
}

with fiona.open(str(fname), 'w', 'ESRI Shapefile', schema) as f:
    f.write(
        {
            'geometry': grid.outline.__geo_interface__,
            'properties': {'name': grid.mesh}
        }
    )