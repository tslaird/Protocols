# Emperical Dynamic Modelling (EDM)


R code for creating time delay embedded animations using the plotly package using example data from the rEDM package


```
library(rEDM)
library(plotly)
library(dplyr)

# obtain the data
series<-paramecium_didinium$didinium

# scale the data
series<-scale(series)

#set the time delay (tau) and create the embedding in 3D with time delayed series
tau<-1
series2<-c(series[(1+tau):length(series)])
series3<-c(series[(1+(2*tau)):length(series)])
time<-c(1:length(series3))

# cut the series to equal lengths
s1<-series[1:length(series3)]
s2<-series2[1:length(series3)]
s3<-series3

# define the accumulate function for creating animated plots in plotly (https://plotly.com/r/cumulative-animations/)
accumulate_by <- function(dat, var) {
  var <- lazyeval::f_eval(var, dat)
  lvls <- plotly:::getLevels(var)
  dats <- lapply(seq_along(lvls), function(x) {
    cbind(dat[var %in% lvls[seq(1, x)], ], frame = lvls[[x]])
  })
  dplyr::bind_rows(dats)
}

# create the initial dataframe
data<-cbind.data.frame(s1,s2,s3,time)

# create the transformed dataframe with frames for animation
data2<-data %>% accumulate_by(~time)

#set lower and upper limits for plotting
low_lim<-round(min(data2[1:3])) -2
high_lim<-round(max(data2[1:3])) +2

# Calculate integer tick values for each axis
x_tickvals <- seq(low_lim, high_lim, by=2)
y_tickvals <- seq(low_lim, high_lim, by=2)
z_tickvals <- seq(low_lim, high_lim, by=2)

# create the plot
p<- data2 %>% plot_ly(
    x = ~s1,
    y = ~s2,
    z= ~s3,
    marker = list(color = "dodgerblue", size=2),
    line = list(color= "dodgerblue",size=2),
    frame = ~frame, 
    mode = 'lines+markers',
    type='scatter3d') %>%
  layout(
  scene= list(camera = list(
                up = list(x = 0, y = 0, z = 1),
                eye = list(x = 1, y = 1, z = 0)),
              aspectratio=list(x=1, y=1, z=1),
              aspectmode='cube',
              tickmode='linear',
              xaxis=list(range=c(low_lim,high_lim), xaxis_autorange=F,
                         tickvals = x_tickvals),
              yaxis=list(range=c(low_lim,high_lim), yaxis_autorange = F,
                         tickvals = y_tickvals),
              zaxis=list(range=c(low_lim,high_lim), zaxis_autorange = F,
                         tickvals = z_tickvals),
              autonormalseg = FALSE)
  ) %>%
  animation_opts(
    frame = 100,
    easing= "linear",
    transition = 0  ) 
p
```
