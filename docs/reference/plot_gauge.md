# Plot Gauge

Plots the last reading of one sensor as a gauge, with the ideal range in
green and a short note on what the gas and particle sensors measure. The
ideal ranges of PM2.5 and PM10 are the 24-hour guidelines of the WHO
(2021); PM1, which has none, gets that of PM2.5. The gas and proximity
sensors have no fixed range, so their gauge is scaled to all the
readings of `data`: it spans the lowest to the highest reading, widened
by one standard deviation, the green band is the mean plus or minus one
standard deviation, and the delta is the difference from the mean.

## Usage

``` r
plot_gauge(data, variable = "Temperature")
```

## Arguments

- data:

  data frame from get_data(); the gauge shows its last reading

- variable:

  one of "Temperature" "Humidity" "Pressure" "Lux" "Proximity" "NH3"
  "Reducing" "Oxidising" "PM1" "PM2.5" "PM10"

## Value

A plotly object.

## Examples

``` r
prometheus_url <- c(
  "http://pip1.crabdance.com:1507/api/v1/query_range",
  "http://pip1.crabdance.com:1505/api/v1/query_range"
)
filtered_df <- get_data(urlq = prometheus_url[1])
plot_gauge(data = filtered_df, variable = "Temperature")

{"x":{"visdat":{"f1a267a45ee98":["function () ","plotlyVisDat"]},"cur_data":"f1a267a45ee98","attrs":{"f1a267a45ee98":{"mode":"gauge+number+delta","value":26.084309146842884,"number":{"suffix":"°C"},"title":{"text":"Temperature","font":{"size":20}},"delta":{"reference":24,"increasing":{"color":"#404444"},"decreasing":{"color":"#404444"}},"gauge":{"axis":{"range":[-50,50],"tickwidth":1,"tickcolor":"darkblue"},"bar":{"color":"red"},"bgcolor":"white","borderwidth":2,"bordercolor":"gray","steps":[{"range":[20,25],"color":"green"}],"threshold":{"line":{"color":"darkblue","width":1},"thickness":5,"value":24}},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"indicator"}},"layout":{"margin":{"b":80,"l":80,"t":50,"r":80,"pad":50},"paper_bgcolor":"white","font":{"color":"darkblue"},"annotations":[{"text":"","x":0.5,"y":-0.10000000000000001,"showarrow":false}],"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"mode":"gauge+number+delta","value":26.084309146842884,"number":{"suffix":"°C"},"title":{"text":"Temperature","font":{"size":20}},"delta":{"reference":24,"increasing":{"color":"#404444"},"decreasing":{"color":"#404444"}},"gauge":{"axis":{"range":[-50,50],"tickwidth":1,"tickcolor":"darkblue"},"bar":{"color":"red"},"bgcolor":"white","borderwidth":2,"bordercolor":"gray","steps":[{"range":[20,25],"color":"green"}],"threshold":{"line":{"color":"darkblue","width":1},"thickness":5,"value":24}},"type":"indicator","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}plot_gauge(data = filtered_df, variable = "Humidity")

{"x":{"visdat":{"f1a265894d29f":["function () ","plotlyVisDat"]},"cur_data":"f1a265894d29f","attrs":{"f1a265894d29f":{"mode":"gauge+number+delta","value":46.986363284469533,"number":{"suffix":"%"},"title":{"text":"Humidity","font":{"size":20}},"delta":{"reference":50,"increasing":{"color":"#404444"},"decreasing":{"color":"#404444"}},"gauge":{"axis":{"range":[0,100],"tickwidth":1,"tickcolor":"darkblue"},"bar":{"color":"red"},"bgcolor":"white","borderwidth":2,"bordercolor":"gray","steps":[{"range":[40,60],"color":"green"}],"threshold":{"line":{"color":"darkblue","width":1},"thickness":5,"value":50}},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"indicator"}},"layout":{"margin":{"b":80,"l":80,"t":50,"r":80,"pad":50},"paper_bgcolor":"white","font":{"color":"darkblue"},"annotations":[{"text":"","x":0.5,"y":-0.10000000000000001,"showarrow":false}],"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"mode":"gauge+number+delta","value":46.986363284469533,"number":{"suffix":"%"},"title":{"text":"Humidity","font":{"size":20}},"delta":{"reference":50,"increasing":{"color":"#404444"},"decreasing":{"color":"#404444"}},"gauge":{"axis":{"range":[0,100],"tickwidth":1,"tickcolor":"darkblue"},"bar":{"color":"red"},"bgcolor":"white","borderwidth":2,"bordercolor":"gray","steps":[{"range":[40,60],"color":"green"}],"threshold":{"line":{"color":"darkblue","width":1},"thickness":5,"value":50}},"type":"indicator","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}plot_gauge(data = filtered_df, variable = "PM2.5")

{"x":{"visdat":{"f1a263abd6c67":["function () ","plotlyVisDat"]},"cur_data":"f1a263abd6c67","attrs":{"f1a263abd6c67":{"mode":"gauge+number+delta","value":24,"number":{"suffix":" µg/m³"},"title":{"text":"PM2.5","font":{"size":20}},"delta":{"reference":0,"increasing":{"color":"#404444"},"decreasing":{"color":"#404444"}},"gauge":{"axis":{"range":[0,400],"tickwidth":1,"tickcolor":"darkblue"},"bar":{"color":"red"},"bgcolor":"white","borderwidth":2,"bordercolor":"gray","steps":[{"range":[0,15],"color":"green"}],"threshold":{"line":{"color":"darkblue","width":1},"thickness":5,"value":0}},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"indicator"}},"layout":{"margin":{"b":80,"l":80,"t":50,"r":80,"pad":50},"paper_bgcolor":"white","font":{"color":"darkblue"},"annotations":[{"text":"Combustion particles,Organic compounds,Metals","x":0.5,"y":-0.10000000000000001,"showarrow":false}],"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"mode":"gauge+number+delta","value":24,"number":{"suffix":" µg/m³"},"title":{"text":"PM2.5","font":{"size":20}},"delta":{"reference":0,"increasing":{"color":"#404444"},"decreasing":{"color":"#404444"}},"gauge":{"axis":{"range":[0,400],"tickwidth":1,"tickcolor":"darkblue"},"bar":{"color":"red"},"bgcolor":"white","borderwidth":2,"bordercolor":"gray","steps":[{"range":[0,15],"color":"green"}],"threshold":{"line":{"color":"darkblue","width":1},"thickness":5,"value":0}},"type":"indicator","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}
```
