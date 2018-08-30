#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$freqDist <- renderPlot({
    
    rfm_data_customer  # 40k rows dataframe
    hist(rfm_data_customer$recency_days, breaks=input$bins, xlab="Days since last visit", ylab="Frequency in the dataset")
    
  })
  
  output$scoreHist <- renderPlot({
    
    analysis_date <- lubridate::as_date('2007-01-01', tz = 'UTC')
    
    # test-driving some lubridate applications
    date1 = rfm_data_customer$most_recent_visit
    a1=date1[1]; a2=date1[2]; a1;a2
    a2-a1  # time differences this easy to do!
    sort(date1[1:20])   # sort() works peacefully.
    
  
    ## use rfm::rfm_table_customer() func  
    rfm_result <- rfm_table_customer(data=rfm_data_customer,
                                    customer_id, 
                                    number_of_orders,
                                    recency_days, 
                                    revenue, 
                                    analysis_date,
                                    recency_bins = 4, frequency_bins = 4, monetary_bins = 4)    # 0.10 secs
  
    rfm_result
      rfm_score = rfm_result$rfm$rfm_score; rfm_score[1:10]
      hist(rfm_score, breaks=input$scorebins)  # pfft. Drop.
      
    freq = table(rfm_score) %>% as.numeric();  
    rfm_vals = unique(rfm_score) %>% sort();  
    freq_tbl = data.frame(rfm_vals, freq); 
  
    
  })
  
  ## use rfm::rfm_table_customer() func  
  rfm_result <- rfm_table_customer(data=rfm_data_customer,
                                    customer_id, 
                                    number_of_orders,
                                    recency_days, 
                                    revenue, 
                                    analysis_date,
                                    recency_bins = 4, frequency_bins = 4, monetary_bins = 4)    # 0.10 secs
  output$graph1 <- renderPlot({
  
    # Heat map output
    rfm_heatmap(rfm_result)
  
  })
  
  output$graph2 <- renderPlot({
  
    # bar chart output
    rfm_bar_chart(rfm_result)
  
  })
  
  output$graph3 <- renderPlot({
  
    # histogram output
    rfm_histograms(rfm_result)
    
  })
  
  output$graph4 <- renderPlot({
  
    rfm_order_dist(rfm_result)
  
  })
  
  output$graph5 <- renderPlot({
  
    # recency vs freq scatterplot
    rfm_rf_plot(rfm_result)
  })
  
  ## Build segment descriptors - tentative
  test_r = rfm_result$rfm$recency_score
  test_f = rfm_result$rfm$frequency_score
  test_m = rfm_result$rfm$monetary_score
  
  min1 = min(test_r); max1 = max(test_r); lowmed1 = floor(max1/2)
  min1; max1; lowmed1
  
  rfm_segments = case_when(
    
    rfm_score == paste0(max1, max1, max1) %>% as.numeric() ~ "best.customers",
    rfm_score == paste0(min1, min1, max1) %>% as.numeric() ~ "lost",
    rfm_score < paste0(min1, min1, lowmed1) %>% as.numeric() ~ "lost n cheap",
    
    test_f == max1 ~ "loyals",
    test_m == max1 ~ "big spenders"    
  )
  
  # replace NA with 'Others'
  a0 = (is.na(rfm_segments));   rfm_segments[a0] = "Others"
  rfm_segments[1:40]
  
  # Calc Segment size
  rfm_segments = rfm_segments %>% 
    data_frame() %>% rename(segment = ".") %>% bind_cols(rfm_data_customer) 
  
  rfm_segments %>%
    count(segment) %>%
    arrange(desc(n)) %>%
    rename(Segment = segment, Count = n)
  
  output$segment1 = renderPlot({
    # median recency
    data <- 
      rfm_segments %>% # data_frame() %>%
      group_by(segment) %>%
      select(segment, recency_days) %>%
      summarize(median(recency_days)) %>%
      rename(segment = segment, avg_recency = `median(recency_days)`) %>%
      arrange(avg_recency) 
    
    n_fill <- nrow(data)
    
    ggplot(data, aes(segment, avg_recency)) +
      geom_bar(stat = "identity", fill = brewer.pal(n = n_fill, name = "Set1")) +
      xlab("Segment") + ylab("Median Recency") +
      ggtitle("Median Recency by Segment") +
      coord_flip() +
      theme(
        plot.title = element_text(hjust = 0.5)
      )
    
  })
  
  output$segment2 = renderPlot({
    
    # Median Monetary Value
    data <- 
      rfm_segments %>%
      group_by(segment) %>%
      select(segment, revenue) %>%
      summarize(median(revenue)) %>%
      rename(segment = segment, avg_monetary = `median(revenue)`) %>%
      arrange(avg_monetary) 
    
    n_fill <- nrow(data)
    
    ggplot(data, aes(segment, avg_monetary)) +
      geom_bar(stat = "identity", fill = brewer.pal(n = n_fill, name = "Set1")) +
      xlab("Segment") + ylab("Median Monetary Value") +
      ggtitle("Median Monetary Value by Segment") +
      coord_flip() +
      theme(
        plot.title = element_text(hjust = 0.5)
      )
    
  })
  
  
})
