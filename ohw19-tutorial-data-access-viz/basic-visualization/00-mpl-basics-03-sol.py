df = df.resample(rule="1H").mean()

df["low"] = df["v"].rolling(window=40, center=True).mean()
df["high"] = df["v"] - df["low"]
df[["v", "high", "low"]].plot(figsize=(11, 3));
