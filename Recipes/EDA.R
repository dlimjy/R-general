##### Some recipes for EDA

# Summaries and overviews -------------------------------------------------
train %>% summary # 5 fig summaries, doesnt do character variables well

# One way plots


# One way plots -----------------------------------------------------------
# Tabulate, response is always second!!!!
gen_tab <- table(train$Sex, train$Survived) %>% as.data.frame.matrix %>% rownames_to_column %>% mutate(rr = `1`/(`1`+`0`)) # Tabulate and calculate response rate

# Plot one way, remember scale your y axis such that geom y = scale_y ^-1
p <- ggplot(gen_tab) + geom_bar(aes(x = rowname, y = total), stat = "identity", fill = "lightblue") + geom_point(aes(x = rowname, y = rr * 600), group = 1, lwd = 1) + geom_line(aes(x = rowname, y = rr * 600), group = 1, lwd = 1) + scale_y_continuous(name = "Total passengers", sec.axis = sec_axis(~.* 1/600, name = "Survival Rate"))


