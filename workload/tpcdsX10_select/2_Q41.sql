-- start query 41 in stream 0 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 776 and 776+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'lime' or i_color = 'mint') and 
        (i_units = 'Tbl' or i_units = 'Cup') and
        (i_size = 'petite' or i_size = 'N/A')
        ) or
        (i_category = 'Women' and
        (i_color = 'blanched' or i_color = 'blue') and
        (i_units = 'Gram' or i_units = 'Each') and
        (i_size = 'small' or i_size = 'extra large')
        ) or
        (i_category = 'Men' and
        (i_color = 'coral' or i_color = 'orchid') and
        (i_units = 'Carton' or i_units = 'Pound') and
        (i_size = 'large' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'seashell' or i_color = 'burlywood') and
        (i_units = 'Gross' or i_units = 'Tsp') and
        (i_size = 'petite' or i_size = 'N/A')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'grey' or i_color = 'olive') and 
        (i_units = 'Ounce' or i_units = 'Dram') and
        (i_size = 'petite' or i_size = 'N/A')
        ) or
        (i_category = 'Women' and
        (i_color = 'firebrick' or i_color = 'smoke') and
        (i_units = 'N/A' or i_units = 'Ton') and
        (i_size = 'small' or i_size = 'extra large')
        ) or
        (i_category = 'Men' and
        (i_color = 'forest' or i_color = 'lemon') and
        (i_units = 'Unknown' or i_units = 'Dozen') and
        (i_size = 'large' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'spring' or i_color = 'deep') and
        (i_units = 'Pallet' or i_units = 'Case') and
        (i_size = 'petite' or i_size = 'N/A')
        )))) > 0
 order by i_product_name
 LIMIT 100;

-- end query 41 in stream 0 using template query41.tpl
