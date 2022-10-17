fig, (ax0, ax1) = plt.subplots(
    figsize=(11, 2.75),
    nrows=2,
    sharex=True,
)

df["001"].plot(ax=ax0)
df["300"].plot(ax=ax1);
