library(ggplot2)
library(dplyr)

# Example data
set.seed(123)
t <- 1:100
f_t <- cumsum(rnorm(100, 0.1, 1)) + 10  # positive, normal scale
g_t <- -exp(cumsum(rnorm(100, 0.05, 0.5)))  # negative, will be log-scaled

# Create a data frame
df <- data.frame(
  time = t,
  f = f_t,
  g = g_t
)

# Transform g(t) for plotting (since log of negative numbers isn't defined)
# Use signed log: sign(x) * log(abs(x) + 1)
df$g_transformed <- -log(-df$g + 1)  # Transform for secondary axis

# Calculate transformation ratio
coeff <- max(df$f) / max(df$g_transformed)

ggplot(df, aes(x = time)) +
  geom_line(aes(y = f, color = "f(t)"), size = 1) +
  geom_line(aes(y = g_transformed * coeff, color = "g(t)"), size = 1) +
  scale_y_continuous(
    name = "f(t) - Normal Scale",
    sec.axis = sec_axis(trans = ~./coeff,
                        name = "g(t) - Log Scale",
                        labels = function(x) round(-exp(-x) + 1, 2))
  ) +
  scale_color_manual(values = c("f(t)" = "blue", "g(t)" = "red")) +
  labs(title = "Dual Y-Axis Plot", x = "Time", color = "Series") +
  theme_minimal()

# More control over the transformation
p2=ggplot(df, aes(x = time)) +
  geom_line(aes(y = f, color = "f(t)"), size = 1) +
  geom_line(aes(y = (g_transformed - min(g_transformed)) / 
                   (max(g_transformed) - min(g_transformed)) * 
                   (max(f) - min(f)) + min(f), 
                color = "g(t)"), size = 1) +
  scale_y_continuous(
    name = "f(t)",
    breaks = pretty(df$f, n = 6),
    sec.axis = sec_axis(
      trans = ~ (. - min(df$f)) / (max(df$f) - min(df$f)) * 
              (max(df$g_transformed) - min(df$g_transformed)) + min(df$g_transformed),
      name = "g(t) (log scale)",
      breaks = pretty(df$g_transformed, n = 6),
      labels = function(x) round(-exp(-x) + 1, 2)
    )
  ) +
  scale_color_manual(values = c("f(t)" = "blue", "g(t)" = "red")) +
  theme_minimal()

library(patchwork)

p1 <- ggplot(df, aes(x = time, y = f)) +
  geom_line(color = "blue", size = 1) +
  labs(y = "f(t) - Normal Scale") +
  theme_minimal()

p2 <- ggplot(df, aes(x = time, y = g)) +
  geom_line(color = "red", size = 1) +
  scale_y_continuous(trans = "log10", labels = scales::comma) +
  labs(y = "g(t) - Log Scale") +
  theme_minimal()

p3=p1 / p2  # Stack vertically
# or p1 | p2 for side-by-side


