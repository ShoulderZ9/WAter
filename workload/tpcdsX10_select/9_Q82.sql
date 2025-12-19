-- start query 82 in stream 0 using template query82.tpl
select  i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, store_sales
 where i_current_price between 49 and 49+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 AND d_date BETWEEN CAST('2000-06-16' AS DATE) AND (CAST('2000-06-16' AS DATE) + INTERVAL '60' DAY)
 and i_manufact_id in (38,311,479,905)
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 LIMIT 100;

-- end query 82 in stream 0 using template query82.tpl
