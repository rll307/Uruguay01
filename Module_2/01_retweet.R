
# Packages ----------------------------------------------------------------
install.packages("rtweet", repos = 'https://ropensci.r-universe.dev/')
library(rtweet)
auth_setup_default()
library(ggplot2)
library(dplyr)
options(scipen = 999)


# Checking the trends -----------------------------------------------------
all.trends <- trends_available()
SaoPaulo.trends <- get_trends(woeid = 455827)


# Searching Tweets --------------------------------------------------------
my.Tweets <-
  search_tweets("Assédio",
                n = 1000,
                include_rts = TRUE)

LulaOficial <- get_timeline("LulaOficial", n = 1000)


# Followers ---------------------------------------------------------------

LulaOficial.flw <- get_followers("LulaOficial", n = 1000)

# Some info

LulaOficial.flw2 <- LulaOficial.flw[1:100,]
info <- lookup_users(LulaOficial.flw2$from_id)

users <- search_users("Assédio", n = 1000)


# Comparisson -------------------------------------------------------------

LuisLacallePou <- get_timeline("LuisLacallePou", n = 1000)
LulaOficial <- get_timeline("LulaOficial", n = 1000)


LulaOficial$screen_name <- "LulaOficial"
LuisLacallePou$screen_name <- "LuisLacallePou"
presidents <- rbind(LulaOficial,LuisLacallePou)

# Saving
presidets.save  <- data.frame(lapply(presidents, as.character), stringsAsFactors=FALSE)
write.csv(presidets.save, "presidents.csv")



# Plotting ----------------------------------------------------------------

# Some initial plotting
LulaOficial %>% ts_plot("month", trim = 7L)
LuisLacallePou %>% ts_plot("month", trim = 7L)

#Localle
LuisLacallePou.p<-presidents  %>%
  subset(created_at > "2023-01-01") %>%
  subset(screen_name == "LuisLacallePou")

ts_plot(LuisLacallePou.p, "days", trim = 0L) +
  ggplot2::geom_point(
    color = "black",
    shape = 21,
    fill = "red",
    size = 3
  ) +
  ggplot2::geom_line(color = "red") +
  ggplot2::theme_minimal() +
  ggplot2::labs(
    x = NULL,
    y = NULL,
    title = "Frequency of Twitter statuses posted by Luis Lacalle Pou",
    subtitle = "Twitter status (tweet) counts aggregated by day from January 2023",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet"
  )


# Lula
Lula.p<-presidents  %>%
  subset(created_at > "2023-01-01") %>%
  subset(screen_name == "LulaOficial")

ts_plot(Lula.p, "days", trim = 0L) +
  ggplot2::geom_point(
    color = "black",
    shape = 21,
    fill = "green",
    size = 3
  ) +
  ggplot2::geom_line(color = "green") +
  ggplot2::theme_minimal() +
  ggplot2::labs(
    x = NULL,
    y = NULL,
    title = "Frequency of Twitter statuses posted by Lula",
    subtitle = "Twitter status (tweet) counts aggregated by day from January 2023",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet"
  )


presidents %>%
  dplyr::filter(created_at > "2023-01-01") %>%
  dplyr::group_by(screen_name) %>%
  ts_plot("day", trim = 15L) +
  ggplot2::geom_point(size = 3, aes(shape = factor(screen_name),color = factor(screen_name))) +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    legend.title = ggplot2::element_blank(),
    legend.position = "bottom",
    plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = NULL, y = NULL,
    title = "Frequency of Twitter statuses posted by Chilean Presidentss",
    subtitle = "Twitter status (tweet) counts aggregated by date",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet"
  )






















