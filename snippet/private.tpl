{% macro main(reject, direct) %}
# > Axure
DOMAIN,www.axure.com,{{ reject }}
# > Apple
DOMAIN-KEYWORD,itunes.apple.com,{{ direct }}
{% endmacro %}
