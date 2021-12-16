-- 1) Вывести отсортированный по количеству перелетов (по убыванию) и имени (по возрастанию) список пассажиров,
-- совершивших хотя бы 1 полет.

SELECT p.name, count(p.id) AS count
FROM Passenger AS p JOIN Pass_in_trip AS pit ON p.id = pit.passenger
GROUP BY p.id
ORDER BY count DESC, name


-- 2) Сколько времени обучающийся будет находиться в школе, учась со 2-го по 4-ый уч. предмет?
SELECT DISTINCT TIMEDIFF(
    (SELECT end_pair FROM Timepair WHERE id = 4),
    (SELECT start_pair FROM Timepair WHERE id = 2)
    )
    AS time
FROM Timepair


-- 3) Выведите список комнат, которые были зарезервированы в течение 12 недели 2020 года.
SELECT DISTINCT Rooms.*
FROM Rooms JOIN Reservations as re ON Rooms.id = re.room_id
WHERE YEAR(start_date) = 2020 and week(start_date, 1) = 12
--week(*, 1) второй аргумент "1" указывается для того, чтобы отсчет недели начинался с понедельника

-- 4) Какой(ие) кабинет(ы) пользуются самым большим спросом?
SELECT classroom
FROM Schedule
GROUP BY classroom
HAVING COUNT(classroom) = (
    SELECT MAX(table_count.count_classroom) --ищем максимум от значения count_classroom в таблице table_count
    FROM (
       SELECT COUNT(classroom) AS count_classroom
       FROM Schedule
       GROUP BY classroom) AS table_count
       )

--5) Для каждой пары последовательных дат, dt1 и dt2, поступления средств (таблица Income_o)
--найти сумму выдачи денег (таблица Outcome_o) в полуоткрытом интервале (dt1, dt2]


-- таблица из 2х столбцов (последовательности дат)
WITH cte_in AS
(SELECT date as dt1, LEAD(date) OVER(ORDER BY date) as dt2
FROM Income_o
GROUP BY date
)
--join к нашей cte при условии, что дата из таблицы Outcome_o попадает в наш интверал (;] <;>=
--группировка для получения суммы out в интервале
SELECT isnull(sum(o.out),0) as qty, cte_in.dt1, cte_in.dt2
FROM cte_in LEFT JOIN Outcome_o o ON cte_in.dt1 < o.date and cte_in.dt2 >= o.date
WHERE cte_in.dt2 IS NOT NULL
GROUP BY cte_in.dt1, cte_in.dt2

--6) Cоставить отчет о битвах кораблей в два суперстолбца

WITH cte AS
    (
    SELECT row_number() over(ORDER BY date, name) rn_1, --присваиваем порядковые номера
    NTILE(2) OVER(ORDER BY date, name) groupn, name, date --разделяем на 2 группы
    FROM Battles
    )

SELECT a.rn_1, a.name, a.date, b.rn_1, b.name, b.date --столбцы итоговой таблицы
FROM (SELECT row_number() over(ORDER BY date, name) rn_2, * --нумеруем строки внутри первой из 2х групп
FROM cte
WHERE groupn = 1) a --

LEFT JOIN -- левый join (если вдруг кол-во битв будет нечетное) по нумерации второго уровня

(SELECT row_number() over(ORDER BY date, name) rn_3, * --нумеруем строки внутри второй из 2х групп
FROM cte WHERE groupn = 2) b

ON a.rn_2 = b.rn_3
