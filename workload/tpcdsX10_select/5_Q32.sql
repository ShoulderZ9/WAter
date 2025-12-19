-- start query 32 in stream 0 using template query32.tpl
select  sum(cs_ext_discount_amt)  as "excess discount amount" 
from 
   catalog_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 579
and i_item_sk = cs_item_sk 
AND d_date BETWEEN '1998-03-06'::date 
    AND (CAST('1998-03-06' AS DATE) + INTERVAL '90 days')
and d_date_sk = cs_sold_date_sk 
and cs_ext_discount_amt  
     > ( 
         select 
            1.3 * avg(cs_ext_discount_amt) 
         from 
            catalog_sales 
           ,date_dim
         where 
              cs_item_sk = i_item_sk 
          and d_date between '1998-03-06' and
                             (cast('1998-03-06' as date) +  INTERVAL '90 days')
          and d_date_sk = cs_sold_date_sk 
      ) 
LIMIT 100;

-- end query 32 in stream 0 using template query32.tpl
