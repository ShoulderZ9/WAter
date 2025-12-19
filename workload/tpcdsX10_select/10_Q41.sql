-- start query 41 in stream 0 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 959 and 959+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'gainsboro' or i_color = 'blue') and 
        (i_units = 'Carton' or i_units = 'Bundle') and
        (i_size = 'small' or i_size = 'medium')
        ) or
        (i_category = 'Women' and
        (i_color = 'beige' or i_color = 'lawn') and
        (i_units = 'Oz' or i_units = 'Pallet') and
        (i_size = 'economy' or i_size = 'extra large')
        ) or
        (i_category = 'Men' and
        (i_color = 'black' or i_color = 'lime') and
        (i_units = 'Bunch' or i_units = 'Box') and
        (i_size = 'N/A' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'tan' or i_color = 'blush') and
        (i_units = 'Gross' or i_units = 'Lb') and
        (i_size = 'small' or i_size = 'medium')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'green' or i_color = 'spring') and 
        (i_units = 'Pound' or i_units = 'Gram') and
        (i_size = 'small' or i_size = 'medium')
        ) or
        (i_category = 'Women' and
        (i_color = 'ivory' or i_color = 'powder') and
        (i_units = 'Unknown' or i_units = 'Ton') and
        (i_size = 'economy' or i_size = 'extra large')
        ) or
        (i_category = 'Men' and
        (i_color = 'puff' or i_color = 'peach') and
        (i_units = 'Dram' or i_units = 'Cup') and
        (i_size = 'N/A' or i_size = 'large')
        ) or
        (i_category = 'Men' and
        (i_color = 'deep' or i_color = 'orchid') and
        (i_units = 'Case' or i_units = 'Tsp') and
        (i_size = 'small' or i_size = 'medium')
        )))) > 0
 order by i_product_name
 LIMIT 100;

-- end query 41 in stream 0 using template query41.tpl
