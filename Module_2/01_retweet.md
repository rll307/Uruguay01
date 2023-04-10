By Rodrigo Esteves de Lima Lopes *University of Campinas* [rll307\@unicamp.br](mailto:rll307@unicamp.br)

------------------------------------------------------------------------

# My first Twitter data scraping

# Introduction

Our main objective is to have a first contact with a data scraping package. In this case, `rtweet`. Twitter has been one of the oldest surviving social media, and it also has been an important source for data in the last few years. But please, take into account that the data we collect might be influenced by a number of factors:

1.  Twitter's algorithm is known to change the results depending of our location
2.  A different kind of account (professional, personal or premium) offers different results
3.  Our Internet band might influence the results

## What are we going to need

1.  A valid [Twitter](https://twitter.com/) account
2.  The Package [rtweet](https://github.com/ropensci/rtweet) for data scraping

### Responsible data use

Please, keep in mind that any data scraping should be done in accordance to Twitter's [terms and conditions](https://developer.twitter.com/en/developer-terms/more-on-restricted-use-cases).

# Scraping some data

Loading the package:

``` r
install.packages("rtweet", repos = 'https://ropensci.r-universe.dev/')
library(rtweet)
auth_setup_default()
library(ggplot2)
library(dplyr)
options(scipen=999)
```

## Twitter locations

First we are going to get some insights on what is trending in our location. So we start by checking which are the locations available:

``` r
all.trends <- trends_available()
```

If we have a close look, `my.trends <- trends_available()` delivers a table with numbers, cities and countries. So we will get the trends by using this ID.

``` r
SaoPaulo.trends <- get_trends(woeid = 455827)
```

Again we have a table. It is a snapshot of Twitter at the moment data were collected, it tends to change, sometimes, by the minute.

## Getting some tweets

In my data, the term **Assédio** called my attention, so I will make a query and scrap some data.

### search_tweets()

It is the basic command to download tweets with the levels of authentication we have. It always returns nice parsed files. However, if you do not have a researcher or premium account, number of instances might be limited (time and number).

Due to time, we will search for some tweets only:

``` r
my.Tweets <-
  search_tweets("Assédio",
                n = 1000,
                include_rts = TRUE)
```

Let us get the timeline form a politician:

``` r
LulaOficial <- get_timeline("LulaOficial", n = 1000)
```

Let us get his followers

``` r
LulaOficial.flw <- get_followers("LulaOficial", n = 1000)
```

Now let us get some information regarding some of those followers

``` r
LulaOficial.flw2 <- LulaOficial.flw[1:100,]
info <- lookup_users(LulaOficial.flw2$from_id)
```

Getting some users who have tweeted about our search term:

``` r
users <- search_users("Assédio", n = 1000)
```

# Timelines

Let us get the timelines for the some presidents in Latin America:

``` r
LulaOficial <- get_timeline("LulaOficial", n = 1000)
LuisLacallePou <- get_timeline("LuisLacallePou", n = 1000)
```

Our next step is identifying the origin of each president:

``` r
LulaOficial$screen_name <- "LulaOficial"
LuisLacallePou$screen_name <- "LuisLacallePou"
presidents <- rbind(LulaOficial,LuisLacallePou)
```

Merging all data, so I can save and use it

Now let us save our data outside R, if I want to analyse the texts in other software:

``` r

presidets.save  <- data.frame(lapply(presidents, as.character), stringsAsFactors=FALSE)
write.csv(presidets.save, "presidents.csv")
```

# Now let us plot the frequency

The basic, one plot for all:

``` r
LulaOficial %>% ts_plot("month", trim = 7L)
LuisLacallePou %>% ts_plot("month", trim = 7L)
```

![Lulas's tweets](images/Lula02.png)

![Lacalle's tweets](images/Localle02.png)

`ts_plot()` is part of `rtweet`. It "borrows" some elements from `ggplot2` in order to plot frequency of tweets as time series. It is possible to make the visual representation a bit more sophisticated by providing multiple text-based filters to subset data. It is also possible to plot multiple time series.

As we can see, this image does not give us much information about the tweets. So let us make the plot a bit more complex, now considering each candidate:

**Luis Lacalle Pou**

``` r
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
```

![Tweets by Localle](images/Localle02.png)

**Lula**

``` r
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
```

![Tweets by Lula](images/Lula02.png)

In the commands above, a number of filters and new criteria changed the way data was represented. In a nutshell we:

1.  chose a single politician
2.  set a data form the timeline to start
3.  set a colour for each candidate
4.  set the size

Now, let us plot all the presidents in a single command:

``` r
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
```

![Lula and Localle](images/Lula_Localle.png)

In a nutshell we:

1.  chose both presidents
2.  grouped the occurrences by screen name
3.  set a data form the timeline to start
4.  set a colour and shape for each candidate
5.  set the size

Which conclusions can we get?
