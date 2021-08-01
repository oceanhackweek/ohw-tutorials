import erddapy

# https://coastwatch.pfeg.noaa.gov/erddap/tabledap/cwwcNDBCMet.html
# get netcdf files
# https://coastwatch.pfeg.noaa.gov/erddap/tabledap/cwwcNDBCMet.nc?station%2Clongitude%2Clatitude%2Ctime%2Cwspd%2Cgst%2Cwvht&time%3E=2021-07-01T00%3A00%3A00Z&time%3C=2021-08-01T22%3A35%3A00Z
default_constraints = {
    "time>=": "2021-01-01T00:00:00Z",
    "time<=": "2021-03-01T00:00:00Z",        
    "wvht>=": 1
}
def load_data(
    constraints = default_constraints,
    variables = ["station", "latitude", "longitude", "time", "wvht", "wspd", "gst"],
    dataset_id = "cwwcNDBCMet"
):
    e = erddapy.ERDDAP("https://coastwatch.pfeg.noaa.gov/erddap/", protocol="tabledap")
    e.dataset_id = dataset_id
    e.variables = variables
    e.constraints = constraints
    df = e.to_pandas(low_memory=False)
    df = df.rename(columns={
        'latitude (degrees_north)': 'latitude',
        'longitude (degrees_east)': 'longitude',
        'time (UTC)': 'time',
        'wvht (m)': 'wvht',
        'wspd (m s-1)': 'wspd',
        'gst (m s-1)': 'gst'
    })
    return df
