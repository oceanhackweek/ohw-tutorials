from datetime import datetime

fname = "15t30717.3f1"
parse = lambda x: datetime.strptime(x, "%Y %m %d %H %M")
names = ["j", "u", "v", "temp", "sal", "y", "mn", "d", "h", "mi"]

df = pd.read_csv(
    f"{url}/{fname}",
    delim_whitespace=True,
    names=names,
    date_parser=parse,
    parse_dates = [["y", "mn", "d", "h", "mi"]],
    index_col="y_mn_d_h_mi",
)

df.head()
