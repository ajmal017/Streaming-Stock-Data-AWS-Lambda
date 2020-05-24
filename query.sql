SELECT name, SUBSTRING(ts, 12, 2) AS hour, MAX(high) AS mhigh
FROM "20" 
GROUP BY 1,2
ORDER BY 1,2
