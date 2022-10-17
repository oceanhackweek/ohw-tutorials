bottom = temp.isel(
    time=-1,
    s_rho=0,
).to_array()

surface.plot(
    x="lon_rho",
    y="lat_rho",
);
