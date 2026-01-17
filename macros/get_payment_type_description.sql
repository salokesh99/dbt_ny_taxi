{#
This macro returns the desc of payment type
#}

{% macro get_payment_type_descr(payment_type) %}


  case cast( {{payment_type}} as integer )
       when 1 then 'cc'
       when 2 then 'Cash'
       when 3 then 'No Charge'
       when 4 then 'Dispute'
       when 5 then 'Unknown'
       when 6 then 'Voided trip'
       else 'EMPTY'
    end

{% endmacro%}