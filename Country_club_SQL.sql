/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name 
FROM Facilities
WHERE membercost <> 0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities 
WHERE membercost <> 0 AND membercost < 0.2*monthlymaintenance;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM Facilities
WHERE facid IN (1,5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	   CASE WHEN monthlymaintenance > 100 THEN 'Expensive'
       ELSE 'Cheap' END AS label
FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT finaltable.name, concat(finaltable.first,' ',finaltable.last) AS member
FROM (SELECT Facilities.name AS name, Members.firstname AS first, Members.surname AS last
	  FROM Facilities
      JOIN Bookings ON Bookings.facid = Facilities.facid
      AND
      Facilities.name LIKE 'Tennis Court%'
      JOIN Members ON Members.memid = Bookings.memid) AS finaltable
GROUP BY name, member
ORDER BY member;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name AS facility, concat(Members.firstname,' ',Members.surname) AS member,
       CASE WHEN Bookings.memid = 0 THEN Bookings.slots * Facilities.guestcost
       ELSE Bookings.slots * Facilities.membercost END AS cost
FROM Facilities
JOIN Bookings ON Bookings.facid = Facilities.facid
AND 
Bookings.starttime LIKE '2012-09-14%'
AND 
(((Bookings.memid = 0) AND (Bookings.slots * Facilities.guestcost > 30))
OR
 ((Bookings.memid <> 0) AND (Bookings.slots * Facilities.membercost > 30))
)

JOIN Members ON Bookings.memid = Members.memid
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT *
FROM
(
    SELECT Facilities.name as facility, concat(Members.firstname,' ',Members.surname) AS member,
	CASE WHEN Bookings.memid =0 THEN Facilities.guestcost * Bookings.slots
	ELSE Facilities.membercost * Bookings.slots END AS cost
	FROM Bookings
	JOIN Facilities ON Bookings.facid = Facilities.facid
	AND 
    Bookings.starttime LIKE  '2012-09-14%'
	JOIN Members ON Bookings.memid = Members.memid
) AS final

WHERE final.cost > 30
ORDER BY final.cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT * 
FROM (
    SELECT final.facility, sum(final.cost) as revenue
    FROM (
        SELECT Facilities.name as facility, 
        CASE WHEN Bookings.memid = 0 THEN (Facilities.guestcost * Bookings.slots)
        ELSE (Facilities.membercost * Bookings.slots)
        END AS cost
                        
        FROM Bookings
        JOIN Facilities ON Bookings.facid = Facilities.facid
        JOIN Members ON Bookings.memid = Members.memid) AS final

    GROUP BY final.facility) AS total
	WHERE total.revenue <1000;
        
        
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT * 
FROM 
	(
        SELECT Members.recommendedby as recommender, concat(Members.surname,' ',Members.firstname) as member
        FROM Bookings
        JOIN Facilities ON Bookings.facid = Facilities.facid
        JOIN Members on Bookings.memid = Members.memid
    ) AS history
GROUP BY history.recommender, history.member
ORDER BY history.recommender DESC;


/* Q12 Find the facilities with their usage by member, but not guests*/
SELECT * 
FROM 
	(
	 SELECT Facilities.name as facility, Members.memid as member
	 FROM Bookings
	 JOIN Facilities ON Bookings.facid = Facilities.facid
	 JOIN Members ON Bookings.memid = Members.memid
    ) AS final
WHERE final.member > 0
GROUP BY final.facility, final.member;


/* Q13: Find the facilities usage by month, but not guests */

SELECT * 
FROM 
	(
        SELECT Facilities.name AS facility, Members.memid AS member, month(Members.joindate) AS joinmonth
		FROM Bookings
		JOIN Facilities ON Bookings.facid = Facilities.facid
		JOIN Members ON Bookings.memid = Members.memid
    ) AS final

GROUP BY final.facility, final.member, final.joinmonth;