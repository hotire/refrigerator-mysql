SELECT AI.ANIMAL_ID, AI.NAME
  from ANIMAL_INS ai INNER join ANIMAL_OUTS ao on ai.ANIMAL_ID = ao.ANIMAL_ID
 where ao.DATETIME < ai.DATETIME
 ORDER BY ai.DATETIME
