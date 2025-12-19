-- start query 37 in stream 0 using template query37.tpl
select  i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, catalog_sales
 where i_current_price between 65 and 65 + 30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
AND d_date BETWEEN CAST('2000-03-22' AS DATE)
    AND (CAST('2000-03-22' AS DATE) + INTERVAL '60 days')
 and i_manufact_id in (728,929,674,955)
 and inv_quantity_on_hand between 100 and 500
 and cs_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 LIMIT 100;

-- end query 37 in stream 0 using template query37.tpl
