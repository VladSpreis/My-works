CREATE DATABASE kinopoisk;

USE kinopoisk;


-- Все, что касается информации о фильме
DROP TABLE IF EXISTS films;
CREATE TABLE films(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255),
 	UNIQUE unique_name(name(10)),
 	country VARCHAR (150),
 	budget DECIMAL (11,2),
 	fees DECIMAL (11,2),
 	premiere_in_world DECIMAL (11,2),
 	premiere DATE,
 	premiere_in_Russia DATE,
 	age BIGINT,
 	rating_MPAA ENUM('G', 'PG', 'PG-13', 'R', 'NC-17')
 	description TEXT
);
SELECT id,name, slogan FROM films;
ALTER TABLE films MODIFY COLUMN fees BIGINT UNSIGNED;
ALTER TABLE films ADD COLUMN slogan VARCHAR (300);
ALTER TABLE films ADD COLUMN time_movie TIME; 
ALTER TABLE films ADD COLUMN production_year YEAR;
ALTER TABLE films RENAME COLUMN slogan TO slogan;
ALTER TABLE films ADD COLUMN marketing DECIMAL;


UPDATE 
DESCRIBE films;
INSERT INTO films(id, name) VALUES
(21, 'Мулен Руж'),
(22, 'Игры разума'),
(23, 'Госфорд-парк'),
(24, 'Черный ястреб');
SELECT person, charaster, profession FROM work_on_the_film WHERE film = films.id;

DROP PROCEDURE movie_page; 


-- Здесь две процелдуры на информацию о фильмах и актерах( некая имитация данных. Так, как они расположены на кинопоиске)
-- На вызове отдельно взяты примеры фильма "Властелин колец"и актера "Леонардо ДиКаприо"


-- Процедура оказывает страничку фильма кинопоиска и всю информацию о нем
delimiter //
CREATE PROCEDURE movie_page(IN movie BIGINT UNSIGNED)
BEGIN 
SELECT id,name,production_year FROM films WHERE id = movie
UNION ALL 
SELECT slogan,country,(SELECT concat((SELECT HOUR(time_movie) * 60 + MINUTE(time_movie)  FROM films WHERE id = movie), 'мин.', '/', ' ', time_movie) FROM films WHERE id = movie ) FROM films WHERE id = movie
UNION ALL 
SELECT (SELECT ('genres')), (SELECT ('premiere_in_world')), (SELECT('premiere_in_Russia'))
UNION ALL 
SELECT (SELECT genre FROM film_genre WHERE film = films.id),premiere_in_world, premiere_in_Russia FROM films WHERE id = movie
UNION ALL 
SELECT (SELECT ('budget')), (SELECT ('fees')), (SELECT('fees_in_Russia'))
UNION ALL 
SELECT budget, fees, fees_in_Russia FROM films WHERE id = movie
UNION ALL 
SELECT (SELECT concat(firstname, ' ', lastname) FROM person WHERE id = work_on_the_film.person), (SELECT name FROM profession_name WHERE id = work_on_the_film.profession), NULL FROM work_on_the_film WHERE film = movie AND profession != 1
UNION ALL
SELECT (SELECT ('Оскар')), NULL, NULL
UNION ALL 
SELECT  (SELECT name FROM catalog_of_nomination_for_picture WHERE id = oscar_for_picture.nomination), NULL,NULL  FROM oscar_for_picture WHERE nominees = movie  AND got = 1
UNION ALL
SELECT (SELECT ('marketing')), (SELECT ('rating_MPAA')), (SELECT('age'))
UNION ALL 
SELECT marketing,rating_MPAA, age FROM films WHERE id = movie
UNION ALL 
SELECT
concat(p1.firstname, ' ', p1.lastname),
concat(p2.firstname, ' ', p2.lastname),
w.personage
FROM dubbing AS d  JOIN person p1 ON d.actor = p1.id
JOIN person AS p2 ON d.voice_actor = p2.id
LEFT JOIN work_on_the_film AS w ON d.actor = w.person 
WHERE d.film = movie  AND w.profession = 1
UNION ALL 
SELECT description, NULL, NULL FROM films WHERE id = movie;
END//
delimiter ;

CALL movie_page(2);

delimiter //
CREATE PROCEDURE page_person(IN p_p BIGINT UNSIGNED)
begin
SELECT user_id, (SELECT concat(firstname, ' ', lastname) FROM person WHERE id = profiles.user_id), carrier FROM profiles WHERE user_id = p_p
UNION ALL
SELECT gender,  height, genre  FROM profiles WHERE user_id =p_p
UNION ALL 
SELECT  (SELECT ((YEAR(CURRENT_DATE) - YEAR(birthday)) - (DATE_FORMAT(CURRENT_DATE, '%m%d') < DATE_FORMAT(birthday, '%m%d'))) AS age
FROM profiles WHERE USER_id = p_p),marital_status, amount_of_children FROM profiles WHERE user_id = p_p
UNION ALL
SELECT ('Кол-во фильмов'), ('Тип_медиа_файла'),('Имя файла')
UNION ALL
SELECT (SELECT DISTINCT count(film) AS total FROM work_on_the_film WHERE person = p_p AND profession = 1), media_types_id, file_name FROM media WHERE USER_id = p_p
UNION ALL
SELECT birthday, city, country FROM profiles WHERE user_id = p_p
UNION ALL 
SELECT ('death'), ('place_of_death'),('country_where_dead')
UNION all
SELECT death, place_of_death, country_where_dead FROM profiles WHERE user_id= p_p
UNION ALL 
SELECT ('About person'), NULL, null
UNION ALL 
SELECT adress, NULL, NULL FROM sites WHERE person = p_p
UNION ALL
SELECT about_person, NULL, NULL FROM about_person WHERE person = p_p;
END//
delimiter ;

CALL page_person(268); 


-- Вид раздела новостей о персоне
CREATE OR REPLACE VIEW news_about_person as
SELECT * FROM news WHERE news_title LIKE '%Леонардо ДиКаприо%' OR body LIKE '%Леонардо ДиКаприо%';
SELECT * FROM news_about_person;

-- Здесь наглядный список из всех фильмов и тех, кто над ними работал
CREATE OR REPLACE VIEW views AS  
SELECT  id,  (SELECT name FROM films WHERE id = work_on_the_film.film) AS film,
(SELECT CONCAT(firstname,' ',lastname) FROM person WHERE id = work_on_the_film.person) AS person,
(SELECT name FROM profession_name WHERE id = work_on_the_film.profession) AS profession, personage
FROM work_on_the_film;

SELECT * FROM views;

SELECT time_movie FROM films WHERE id =1;

SELECT MIN_FOR_TIME((SELECT time_movie FROM films WHERE id =1));

UPDATE films
SET time_movie = '2:58'
WHERE id = 1;

UPDATE films 
SET marketing = '50000000'
WHERE id = 1;






SELECT HOUR(time_movie) * 60 + MINUTE(time_movie) FROM films WHERE id = 1;
SELECT str_to_date((SELECT time_movie FROM films WHERE id =1), '%hh.%mi');

SELECT concat((SELECT HOUR(time_movie) * 60 + MINUTE(time_movie) FROM films WHERE id = 1), 'мин.', '/', ' ', time_movie) AS timing  FROM films WHERE id = 1;




SELECT(SELECT concat(firstname, ',', lastname) FROM person WHERE id = wo) FROM work_on_the_film wotf WHERE film = 1;

SELECT  id,  (SELECT name FROM films WHERE id = work_on_the_film.film) AS film,
(SELECT CONCAT(firstname,' ',lastname) FROM person WHERE id = work_on_the_film.person) AS person,
(SELECT name FROM profession_name WHERE id = work_on_the_film.profession) AS profession, personage
FROM work_on_the_film;
 

SELECT charaster FROM work_on_the_film wot WHERE (SELECT name FROM profession_name  WHERE id =1) AND (SELECT name FROM films WHERE id = 1);

SELECT charaster FROM work_on_the_film WHERE film = 1;

('Same Make. Same Model. New Mission',) WHERE id = 2
('«Генерал, ставший рабом. Раб, ставший гладиатором. Гладиатор, бросивший вызов империи»',) WHERE id = 3
('«Кинороман в 2-ух частях из жизни контрабандистов»',) WHERE id = 4
('«One adventure will change two worlds»',) WHERE id = 5
('«Ничто на Земле не сможет разлучить их»',) WHERE id = 6
('«Avengers Assemble!»',) WHERE id = 7
('«the time is now»',) WHERE id = 8
('«Together again...»',) WHERE id = 9
('—',) WHERE id = 10
('«15 лет в заточении. 5 дней, чтобы отомстить»',) WHERE id = 11
('«Найди злоумышленника»',) WHERE id = 12
('—',) WHERE id = 13
('«1936 год... Подмосковье... Мелодрама в ритме сентиментального танго»',) WHERE id = 14
('«Что может вернуть любовь?»',) WHERE id = 15
('«What is the key to life - power, prestige or peace?»',) WHERE id = 16
('«Вы не можете остановить того, кого не видно»',) WHERE id = 17
('«Just because you are a character doesnt mean you have character»',) WHERE id = 18
('«Ну, заяц! Ну, погоди!»',) WHERE id = 19
('«Over 3000 islands of paradise. For some it’s a blessing. For others… It’s A Curse»',) WHERE id = 20

-- Добавить время, маркетинг, отдельно сборы в США, год производства 
INSERT INTO films 
VALUES (1, 'Властелин колец: Братство кольца', 'Новая Зеландия, США', 93000000 ,880839846 , 7179834, '2001-11-10','2002-02-07', 12, 'PG-13',
'Сказания о Средиземье — это хроника Великой войны за Кольцо, длившейся не одну тысячу лет. Тот, кто владел Кольцом, получал неограниченную власть, но был обязан служить злу.
Тихая деревня, где живут хоббиты. Придя на 111-й день рождения к своему старому другу Бильбо Бэггинсу, волшебник Гэндальф начинает вести разговор о кольце, которое Бильбо нашел много лет назад. Это кольцо принадлежало когда-то темному властителю Средиземья Саурону, и оно дает большую власть своему обладателю. Теперь Саурон хочет вернуть себе власть над Средиземьем. 
Бильбо отдает Кольцо племяннику Фродо, чтобы тот отнёс его к Роковой Горе и уничтожил.');

INSERT INTO films VALUES (2, 'Терминатор 2: Судный день', 'CША, Франция', 102000000, 516950043, 705164, '1991-06-01', '1994-06-06', 18, 'R',
'Прошло более десяти лет с тех пор, как киборг из 2029 года пытался уничтожить Сару Коннор — женщину, чей будущий сын выиграет войну человечества против машин.
Теперь у Сары родился сын Джон и время, когда он поведёт за собой выживших людей на борьбу с машинами, неумолимо приближается. Именно в этот момент из постапокалиптического будущего прибывает новый терминатор — практически неуязвимая модель T-1000, способная принимать любое обличье. Цель нового терминатора уже не Сара, а уничтожение молодого Джона Коннора.
Однако шансы Джона на спасение существенно повышаются, когда на помощь приходит перепрограммированный сопротивлением терминатор предыдущего поколения. Оба киборга вступают в смертельный бой, от исхода которого зависит судьба человечества.');

INSERT INTO films VALUES (3, 'Гладиатор', 'США, Великобритания, Мальта, Марокко', 103000000, 187705427, 1280000, '2000-05-1', '2000-05-18', 16, 'R',
'В великой Римской империи не было военачальника, равного генералу Максимусу. Непобедимые легионы, которыми командовал этот благородный воин, боготворили его и могли последовать за ним даже в ад.
Но случилось так, что отважный Максимус, готовый сразиться с любым противником в честном бою, оказался бессилен против вероломных придворных интриг. Генерала предали и приговорили к смерти. Чудом избежав гибели, Максимус становится гладиатором.
Быстро снискав себе славу в кровавых поединках, он оказывается в знаменитом римском Колизее, на арене которого он встретится в смертельной схватке со своим заклятым врагом...');

INSERT INTO films VALUES (4, 'Бриллиантовая рука', 'СССР', NULL, NULL, NULL, '1969-04-28', '1969-04-28', 16, 'PG-13',
'В южном городке орудует шайка валютчиков, возглавляемая Шефом и его помощником Графом (в быту — Геной Козодоевым). Скромный советский служащий и примерный семьянин Семен Семенович Горбунков отправляется в зарубежный круиз на теплоходе, 
где также плывет Граф, который должен забрать бриллианты в одном из восточных городов и провезти их в загипсованной руке. Но из-за недоразумения вместо жулика на условленном месте падает ничего не подозревающий Семен Семенович, и драгоценный гипс накладывают ему.');

INSERT INTO films VALUES (5, 'Как приручить дракона', 'США', 165000000, 494878759, 23485237, '2010-03-18', '2010-03-18', 6, 'PG',
'Вы узнаете историю подростка Иккинга, которому не слишком близки традиции его героического племени, много лет ведущего войну с драконами. Мир Иккинга переворачивается с ног на голову, когда он неожиданно встречает дракона Беззубика, 
который поможет ему и другим викингам увидеть привычный мир с совершенно другой стороны…');

INSERT INTO films VALUES (6, 'Титаник', 'США, Мексика, Австралия', 200000000, 1843478449, 18400000, '1997-11-01', '1996-02-20', 12, 'PG-13',
'В первом и последнем плавании шикарного «Титаника» встречаются двое. Пассажир нижней палубы Джек выиграл билет в карты, а богатая наследница Роза отправляется в Америку, чтобы выйти замуж по расчёту. 
Чувства молодых людей только успевают расцвести, и даже не классовые различия создадут испытания влюблённым, а айсберг, вставший на пути считавшегося непотопляемым лайнера.');

INSERT INTO films VALUES(7, 'Мстители', 'США', 220000000, 1518812988, 43412056, '2012-04-11', '2012-05-03', 12, 'PG-13',
'Локи, сводный брат Тора, возвращается, и в этот раз он не один. Земля оказывается на грани порабощения, и только лучшие из лучших могут спасти человечество. Глава международной организации Щ.И.Т. Ник Фьюри собирает выдающихся поборников справедливости и добра, чтобы отразить атаку. Под предводительством Капитана Америки Железный Человек, 
Тор, Невероятный Халк, Соколиный Глаз и Чёрная Вдова вступают в войну с захватчиком.');


INSERT INTO films VALUES(8, '2001 год: Космическая одиссея', 'Великобритания, США', 12000000, 57287357, 152691, '1968-04-02', '2018-07-30' , 12, 'G',
'Экипаж космического корабля «Дискавери» — капитаны Дэйв Боумэн, Фрэнк Пул и их бортовой компьютер HAL 9000 — должны исследовать район галактики и понять, почему инопланетяне следят за Землей. 
На этом пути их ждет множество неожиданных открытий.');

INSERT INTO  films VALUES(9, 'Папаши', 'Франция', NULL, NULL, NULL, '1983-11-23', NULL, 12, 'PG',
'Подросток сбегает из дома вместе со своей подружкой. Полиция оказывается бессильна, и тогда мать решает обратиться к двум старым знакомым, с которыми она когда-то встречалась. Чтобы у них был стимул искать мальчишку, она сообщает каждому из них, что именно он приходится отцом мальчику. 
Журналист, имеющий вечные неприятности с криминальными элементами, и школьный учитель, вечно помышляющий о суициде, вместе отправляются на поиски. Они не знают, что искать им придется одного и того же человека.'
);

INSERT INTO films VALUES(10, 'Укрощение строптивого', 'Италия', NULL, NULL, NULL, '1980-12-20,', NULL, 12, 'PG',
'Категорически не приемлющий женского общества грубоватый фермер вполне счастлив и доволен своей холостяцкой жизнью. 
Но неожиданно появившаяся в его жизни женщина пытается изменить его взгляды на жизнь и очаровать его.'
);

INSERT INTO films VALUES (11, 'Олдбой', 'Южная Корея', 3000000, 14980005, 170000, '2003-11-21', '2004-11-18', 18, 'R',
'1988 год. Обыкновенный и ничем непримечательный бизнесмен О Дэ-cу в день трёхлетия своей дочери по пути домой напивается, начинает хулиганить и закономерно попадает в полицейский участок. Из участка его под своё поручительство забирает друг детства. Пока тот звонит жене незадачливого пьяницы, О Дэ-су пропадает. 
Неизвестные похищают его и помещают в комнату без окон на 15 лет.'
);

INSERT INTO films VALUES(12, 'Паразиты', 'Южная Корея', 11800000, 266600532, 1630822, '2019-05-19', '2019-07-04', 18, 'R',
'Обычное корейское семейство Кимов жизнь не балует. Приходится жить в сыром грязном полуподвале, воровать интернет у соседей и перебиваться случайными подработками. Однажды друг сына семейства, уезжая на стажировку за границу, предлагает тому заменить его и поработать репетитором у старшеклассницы в богатой семье Пак. 
Подделав диплом о высшем образовании, парень отправляется в шикарный дизайнерский особняк и производит на хозяйку дома хорошее впечатление. Тут же ему в голову приходит необычный план по трудоустройству сестры.'
);

INSERT INTO films VALUES (13, 'Бьютифул', 'Мексика, Испания', NULL, 25147786, 280344, '2010-03-10', '2011-02-24', 18, 'R',
'Разведенный отец двоих детей Уксбаль – свой человек в теневом мире Барселоны. Для правоохранительных органов он – нарушитель закона; для нелегальных иммигрантов, которым помогает получить работу, - добрый ангел. 
Узнав, что неизлечимо болен, Уксбаль начинает готовиться к смерти...'
);

INSERT INTO films VALUES (14, 'Утомленные солнцем', 'Россия, Франция', 2800000, NULL, 160000, '1994-02-07', '1994-11-02', 16, 'R',
'Солнечный летний день 1936 года. Молодая страна, полная энтузиазма, празднует 4-ю годовщину сталинского дирижаблестроения. Легендарный комдив Котов и его большая шумная семья отдыхают на даче. 
В старом доме собралась тьма народу: жена-красавица, непоседа-дочь, тесть - известный русский дирижер, родственники и друзья, домработницы и соседи.
Веселье бьет через край, и мысль, что что-то в жизни может измениться, покажется всем абсурдом. Они все будут счастливы вечно!
И никто, даже мудрый Котов, не хочет верить в неизбежное. В то, что этот солнечный день кончится - и не повторится уже никогда.'
);

INSERT INTO films VALUES (15, 'Миллионер из трущоб', 'Великобритания, США, Индия', 15000000, 377910544, 3629828, '2008-08-30', '2009-02-09', 12, 'R',
'Джамал Малик, 18-летний сирота из трущоб в Мумбаи, всего в одном шаге от победы в телеигре «Кто хочет стать миллионером?» и выигрыша 20 миллионов рупий. Прервав игру, его арестовывает полиция по подозрению в мошенничестве. Откуда юнец, выросший на улице, может знать так много?
На допросе в полиции Джамал рассказывает печальную историю своей жизни: о пережитых приключениях вместе с братом, о стычках с местными бандами, о своей трагической любви. Каждая глава личной истории удивительным образом дала ему ответы на вопросы телевикторины.
Когда игру возобновят, инспектору полиции и шестидесяти миллионам зрителей захочется выяснить ответ только на один вопрос: зачем этот юноша, без явного стремления к богатству, решил принять участие в телепрограмме?'
);


INSERT INTO films  VALUES (16, 'Красная борода', 'Япония', NULL, NULL, NULL, '1965-04-03', '2001-12-03', 16, 'R',
'Красная Борода - это прозвище врача больницы для бедных, в которую после университета попадает молодой честолюбивый доктор Ясумото. Он не принимает порядков, царящих в больнице, строгости и грубости доктора. Только со временем Ясумото понимает, что за жесткостью и суровостью Красной Бороды скрывается безграничная доброта,
 высокая нравственность и подлинное милосердие. Он постигает истинное предназначение врача и признает его своим учителем.'
);

INSERT INTO films VALUES (17, 'Леон', 'США, Франция', 115000000, 19552639, NULL, '1994-09-14', '1995-02-27', 16, 'R',
'Профессиональный убийца Леон неожиданно для себя самого решает помочь 11-летней соседке Матильде,
 семью которой убили коррумпированные полицейские.'
);

INSERT INTO films VALUES (18, 'Криминальное чтиво', 'США', 8000000, 213928762, 83843, '1994-05-21', '1995-09-25', 18, 'R',
'Двое бандитов Винсент Вега и Джулс Винфилд ведут философские беседы в перерывах между разборками и решением проблем с должниками криминального босса Марселласа Уоллеса.
В первой истории Винсент проводит незабываемый вечер с женой Марселласа Мией. Во второй рассказывается о боксёре Бутче Кулидже, купленном Уоллесом, чтобы сдать бой.
 В третьей истории Винсент и Джулс по нелепой случайности попадают в неприятности.'
);

INSERT INTO films VALUES (19, 'Ну погоди', 'СССР', NULL, NULL, NULL, '1969-06-14', NULL, 0, 'G', 
'Веселые приключения неразлучной парочки - хулигана Волка и смышленого Зайца. Любимые с детства сцены погонь,
 ссор и примирений, шутки и мелодии');


INSERT INTO films VALUES (20, 'Пираты карибского моря', 'США', 140000000, 654264015, 9060000, '2003-06-28', '2003-08-20', 12, 'PG-13',
'Жизнь харизматичного авантюриста, капитана Джека Воробья, полная увлекательных приключений, резко меняется, когда его заклятый враг капитан Барбосса похищает корабль Джека Черную Жемчужину, а затем нападает на Порт Ройал и крадет прекрасную дочь губернатора Элизабет Свонн.
Друг детства Элизабет Уилл Тернер вместе с Джеком возглавляет спасательную экспедицию на самом быстром корабле Британии, чтобы вызволить девушку и заодно отобрать у злодея Черную Жемчужину. Вслед за этой парочкой отправляется амбициозный коммодор Норрингтон, который к тому же числится женихом Элизабет.
Однако Уилл не знает, что над Барбоссой висит вечное проклятие, при лунном свете превращающее его с командой в живых скелетов. Проклятье будет снято лишь тогда, когда украденное золото Ацтеков будет возвращено пиратами на старое место.'
);

SELECT id, name FROM films WHERE id =;

ALTER TABLE films ADD COLUMN description TEXT;

DROP TABLE IF EXISTS work_on_the_film;

-- Здесь будет список тех кто работал над фильмом (режиссер, актеры и т.д )

CREATE TABLE work_on_the_film(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	film BIGINT UNSIGNED,
	person BIGINT UNSIGNED NOT NULL,
	profession BIGINT UNSIGNED NOT NULL,
	personage VARCHAR (150) DEFAULT NULL,
	FOREIGN KEY (profession) REFERENCES profession_name (id),
	FOREIGN KEY (person) REFERENCES person (id),
	FOREIGN KEY (film) REFERENCES films(id)
);

-- Питер Джексон- сценарист и актер(добавить и туда и туда), Джеймс Кэемрон0- еще и продюссер
DESCRIBE work_on_the_film;
SHOW INDEX FROM work_on_the_film;
ALTER TABLE work_on_the_film RENAME COLUMN сharaster TO personage;
ALTER TABLE work_on_the_film ADD COLUMN сharaster VARCHAR (150) DEFAULT NULL;
ALTER TABLE work_on_the_film  DROP INDEX person;
ALTER TABLE work_on_the_film DROP column profession;
alter TABLE work_on_the_film DROP COLUMN person;
ALTER TABLE work_on_the_film DROP CONSTRAINT work_on_the_film_ibfk_2;
ALTER TABLE work_on_the_film DROP CONSTRAINT dubbing_ibfk_1;
SELECT * FROM person WHERE id BETWEEN 232 AND 255;
SELECT * FROM work_on_the_film;
SELECT id FROM person WHERE firstname = 'Джеймс' AND lastname = 'Кэмерон';
-- Добавление работающих над фильмом Властелин колец
-- 1) Режиссеры, сценаристы, продюссеры 

-- Выводим всех участвующих в разработке над фильмом по их именам и их должностям
SELECT  id,  (SELECT name FROM films WHERE id = work_on_the_film.film) AS film,
(SELECT CONCAT(firstname,' ',lastname) FROM person WHERE id = work_on_the_film.person) AS person,
(SELECT name FROM profession_name WHERE id = work_on_the_film.profession) AS profession, personage
FROM work_on_the_film WHERE film = 20;

INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(1, 2, 101),
(1,3,101),(1,3, 102),(1,3, 103),(1,4, 101),
(1,4, 104),(1,4,105),(1,4,102),(1,4,106),(1,4,107),
(1,12,108),(1,12,109),(1,4,110),(1,11,111),(1,4,112),
(1,4,113);
-- 2)Оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(1,5,115),(1,6,116),(1,7,117),(1,7,118),
(1,14,119),(1,7,120),(1,7,121),(1,7,121),(1,13,122),
(1,13,123),(1,14,124);
INSERT INTO work_on_the_film (film, profession, person)
VALUES(1,8,125);
-- 3) Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(1,1,126),(1,1,127),(1,1,128),
(1,1,129),(1,1,130),(1,1,131),(1,1,132),(1,1,133),
(1,1,134),(1,1,135),(1,1,136),(1,1,137),(1,1,138),
(1,1,139),(1,1,140),(1,1,141),(1,1,142),(1,1,143),
(1,1,144),(1,1,145),(1,1,146),(1,1,147),(1,1,148),(1,1,149),(1,1,150);


-- Добавление работающих над фильмом Терминатор
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(2,2,151),(2,3,151),(2,3,152),(2,4,153),(2,4,151),(2,4,154),
(2,4,155),(2,5,156),(2,6,157),(2,7,158),(2,7,159),(2,13,160),(2,8,161),(2,8,162),(2,8,163);
-- 2)Актер
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(2,1,164),(2,1,165),(2,1,166),(2,1,167),(2,1,168),(2,1,169),(2,1,170),(2,1,171),
(2,1,172),(2,1,173),(2,1,174),(2,1,175),(2,1,176),(2,1,177),(2,1,178),(2,1,179),(2,1,180);

-- Добавление работающих над фильмом Гладиатор
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(3,2,181),(3,3,182),(3,3,183),(3,3,184),(3,4,182),(3,4,185),(3,4,186),(3,4,187),
(3,11,188),(3,4,189),(3,5,190),(3,6,191),(3,6,192),(3,7,193),(3,13,194),(3,14,195),(3,14,195),(3,8,197);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES (3,1,198),(3,1,199),(3,1,201),(3,1,202),(3,1,203),(3,1,204),(3,1,205),
(3,1,206),(3,1,207),(3,1,208),(3,1,209),(3,1,210),(3,1,211);


-- Добавление работающих над фильмом Бриллиантовая рука
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(4,2,212),(4,3,212),(4,3,213),(4,3,214),(4,5,216),(4,6,217),(4,7,218),(4,8,219);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(4,1,220),(4,1,221),(4,1,222),(4,1,223),(4,1,224),(4,1,225),
(4,1,226),(4,1,227),(4,1,228),(4,1,239),(4,1,230),(4,1,231);

SELECT * FROM person WHERE id BETWEEN 243 AND 255;
-- Добавление работающих над фильмом "Как приручить дракона"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(5,2,232),(5,2,233),(5,3,234),(5,3,232),(5,3,233),(5,3,235),
(5,3,236),(5,5,237),(5,6,238),(5,7,239),(5,7,240),(5,8,241),(5,8,242);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(5,1,243),(5,1,244),(5,1,245),(5,1,246),(5,1,247),(5,1,248), (5,1,249),
(5,1,250),(5,1,251),(5,1,252),(5,1,253),(5,1,254);


SELECT * FROM person WHERE id BETWEEN 313 AND 333;
SELECT id FROM person WHERE firstname = 'Франсис' AND  lastname = 'Вебер';
-- Добавление работающих над фильмом "Титаник"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(6,2,151),(6,3,151),(6,4,255),(6,11,256),(6,12,257),(6,12,258),(6,12,259),
(6,4,260),(6,5,261),(6,6,262),(6,7,263),(6,7,264),(6,7,265),(6,13,266),(6,14,267);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(6,1,268),(6,1,269),(6,1,270),(6,1,271),(6,1,272),(6,1,273),(6,1,274),
(6,1,275),(6,1,276),(6,1,277),(6,1,278),(6,1,279),(6,1,280),(6,1,281),(6,1,282);

-- Добавление работающих над фильмом "Мстители"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(7,2,283),(7,3,283),(7,3,284),(7,4,285),(7,4,286),(7,4,287),(7,4,288),(7,4,289),(7,4,290),(7,4,291)
,(7,4,292),(7,5,293),(7,6,294),(7,7,295),(7,7,296),(7,7,297),(7,13,298),(7,14,299),(7,8,300),(7,8,301);

-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(7,1,302),(7,1,303),(7,1,304),(7,1,305),
(7,1,306),(7,1,307),(7,1,308),(7,1,309),
(7,1,310),(7,1,311),(7,1,312);


SELECT * FROM person WHERE id BETWEEN 324 AND 333;
SELECT id FROM person WHERE  lastname = 'Кубрик';
-- Добавление работающих над фильмом "2001 Космическая одиссея"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(8,2,313),(8,3,314),(8,3,313),(8,4,313),(8,4,315),
(8,5,316),(8,7,317),(8,7,318),(8,7,319),(8,7,320),(8,13,321),(8,14,322),(8,8,323);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(8,1,324),(8,1,325),(8,1,326),(8,1,327),(8,1,328),(8,1,329),
(8,1,330),(8,1,331),(8,1,332);


SELECT * FROM person WHERE id BETWEEN 460 AND 469;
SELECT id FROM person WHERE firstname = 'Дэнни' AND  lastname = 'Бойл';
-- Добавление работающих над фильмом "Папаши"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(9,2,333),(9,4,334),(9,4,335),(9,4,333),(9,5,336),(9,6,337),(9,7,338),(9,7,339),(7,8,340);

-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(9,1,334),(9,1,335),(9,1,341),(9,1,342),(9,1,343),
(9,1,344),(9,1,345),(9,1,346),(9,1,347),(9,1,348),(9,1,349);


-- Добавление работающих над фильмом "Укрощение строптивого"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(10,2,349),(10,2,350),(10,3,349),(10,3,350),(10,3,351),(10,4,352),
(10,4,353),(10,5,354),(10,6,355),(10,7,356),(10,7,357),(10,8,358);

-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(10,1,359),(10,1,360),(10,1,361),(10,1,362),(10,1,363),(10,1,364),(10,1,365);

-- Добавление работающих над фильмом "Олдбой"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(11,2,366),	(11,3,366),(11,3,367),(11,3,368),(11,4,369),(11,4,370),(11,4,372),(11,5,90),(11,5,91),(11,5,92),(11,6,373),(11,6,374),(11,7,375),(11,7,376),(11,13,377),(11,8,378),(11,8,379);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(11,1,380),(11,1,381),(11,1,382),(11,1,383),(11,1,384),(11,1,385),(11,1,386),
(11,1,387),(11,1,388),(11,1,389),(11,1,390),(11,1,391),(11,1,39);

-- Добавление работающих над фильмом "Паразиты"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(12,2,392),(12,3,392),(12,3,393),(12,4,394),(12,4,395),(12,4,396),(12,12,397),(12,12,398),(12,5,399),(12,6,400),(12,7,401),(12,7,402),(12,8,403);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(12,1,404),(12,1,405),(12,1,406),(12,1,407),(12,1,408),(12,1,409),(12,1,410),(12,1,411),(12,1,412),(12,1,413),(12,1,414),(12,1,415),(12,1,416);

-- Добавление работающих над фильмом "Бьютифул"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(13,2,417),(13,3,417),(13,3,418),(13,3,419),(13,4,420),(13,4,421),(13,11,422),(13,11,423),(13,12,424),
(13,4,417),(13,4,425),(13,12,426),(13,5,427),(13,6,428),(13,7,429),(13,7,430),(13,7,431),(13,13,432),(13,13,433),(13,14,434),(13,8,435);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(13,1,436),(13,1,437),(13,1,438),(13,1,439),(13,1,440),(13,1,441),(13,1,442),(13,1,443),(13,1,444),(13,1,445);

-- Добавление работающих над фильмом "Утомленные солнцем"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(14,2,446),(14,3,447),(14,3,446),(14,4,448),(14,4,446),(14,4,449),(14,4,450),
(14,4,451),(14,4,452),(14,5,453),(14,6,454),(14,6,455),(14,7,456),(14,7,457),(14,7,458),(14,8,459);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(14,1,460),(14,1,461),(14,1,462),(14,1,463),(14,1,464),(14,1,465),(14,1,466),(14,1,467),(14,1,468),(14,1,469);

SELECT * FROM person WHERE id BETWEEN 598 AND 657;
SELECT id FROM person WHERE firstname = 'Вячеслав' AND  lastname = 'Котеночкин';

-- Добавление работающих над фильмом "Миллионер из трущоб"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(15,2,469),(15,2,470),(15,3,471),(15,3,472),(15,4,473),(15,4,474),(15,11,475),(15,4,476),(15,15,477),
(15,12,480),(15,5,481),(15,6,482),(15,7,483),(15,7,484),(15,7,485),(15,8,486);

-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(15,1,487),(15,1,488),(15,1,489),(15,1,490),(15,1,491),(15,1,492),(15,1,493),(15,1,494),(15,1,495),(15,1,496);

-- Добавление работающих над фильмом "Красная борода"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(16,2,519),(16,3,520),(16,3,521),(16,3,522),(16,4,522),(16,4,524),(16,5,525),(16,5,526),(16,6,527),(16,7,528),(16,7,529);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(16,1,530),(16,1,531),(16,1,532),(16,1,533),(16,1,534),(16,1,535),(16,1,536),(16,1,537),(16,1,538),(16,1,539);

-- Добавление работающих над фильмом "Леон"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(17,2,540),(17,3,540),(17,4,541),(17,4,542),(17,4,543),(17,5,544),(17,6,545),(17,7,546),(17,7,547),(17,13,548),(17,14,549),(17,8,550);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES 
(17,1,551),(17,1,552),(17,1,553),(17,1,554),(17,1,555),(17,1,556),(17,1,557),(17,1,558),(17,1,559),(17,1,560);

-- Добавление работающих над фильмом "Криминальное чтиво"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(18,2,585),(18,3,585),(18,3,586),(18,4,587),(18,4,588),(18,4,589),(18,4,590),(18,4,591),(18,4,113),(18,4,112),(18,5,592),(18,7,593),(18,7,594),(18,13,595),(18,14,596),(18,8,597);
SELECT id FROM person WHERE firstname = 'Боб' AND lastname = 'Вайнштейн';

-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(18,1,598),(18,1,599),(18,1,600),(18,1,601),(18,1,602),(18,1,603),(18,1,604),(18,1,605),(18,1,606),(18,1,607);


SELECT * FROM person WHERE id BETWEEN 720 AND 728;
SELECT id FROM person WHERE firstname = 'Джонни' AND  lastname = 'Депп';
SELECT id FROM person WHERE firstname = 'Гор' AND lastname = 'Вербински';
-- Добавление работающих над фильмом "Ну погоди"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(19,2,657),(19,2,658),(19,2,659),(19,3,660),(19,3,661),(19,3,662),(19,5,663),(19,5,664),(19,5,665),
(19,5,666),(19,6,667),(19,6,217),(19,6,668),(19,7,669),(19,7,670),(19,7,671),(19,7,672),(19,8,673),(19,8,674);
SELECT id FROM person WHERE firstname = 'Александр' AND lastname = 'Зацепин';
SELECT id FROM person WHERE firstname = 'Джерри' AND lastname = 'Брукхаймер';
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(19,1,675),(19,1,676),(19,1,677),(19,1,678),(19,1,679);

-- Добавление работающих над фильмом "Пираты карибского моря"
-- 1) Режиссеры, сценаристы, продюссеры, оператор, художники, монтажеры, композитор
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(20,2,705),(20,3,706),(20,4,707),(20,4,93),(20,5,710),(20,6,711),(20,7,712),(20,7,713),(20,7,714),(20,13,715),(20,14,716),(20,8,717),(20,8,718),(20,8,719);
-- 2)Актеры
INSERT INTO work_on_the_film (film, profession, person)
VALUES
(20,1,720),(20,1,721),(20,1,722),(20,1,723),(20,1,724),(20,1,725),(20,1,726),(20,1,727),(20,1,728);



-- Снова вернуть ссылку на таблицу "работа над фильмом"
CREATE TABLE dubbing (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	film BIGINT UNSIGNED,
	voice_actor BIGINT UNSIGNED NOT NULL,
	actor BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (film) REFERENCES work_on_the_film(film),
	FOREIGN KEY (voice_actor) REFERENCES person (id),
	FOREIGN KEY (actor) REFERENCES work_on_the_film(person)
);
SELECT  id,  (SELECT name FROM films WHERE id = work_on_the_film.film) AS film,
(SELECT CONCAT(firstname,' ',lastname) FROM person WHERE id = work_on_the_film.person) AS person,
(SELECT name FROM profession_name WHERE id = work_on_the_film.profession) AS profession, personage, person 
FROM work_on_the_film WHERE film = 1;


SELECT* FROM person WHERE id >729;
truncate TABLE dubbing;
SELECT * FROM person WHERE id >728 ORDER BY id;
SELECT * FROM dubbing;


INSERT INTO dubbing(film, voice_actor,actor) VALUES
(1, 729, 126),
(1, 729, 127),
(1, 729, 128),
(1, 729, 129),
(1, 729, 130),
(1, 729, 131),
(1, 729, 132),
(1, 729, 133),
(1, 729, 134),
(1, 729, 135);
INSERT INTO dubbing(film, voice_actor,actor) VALUES
(2, 738, 164),
(2, 739, 165),
(2, 740, 166),
(2, 741, 167),
(2, 742, 168),
(2, 743, 169),
(2, 744, 170),
(2, 745, 171),
(2, 746, 172),
(2, 747, 173),
(2, 748, 174);

Process finished with exit code 0




ALTER TABLE dubbing DROP CONSTRAINT dubbing_ibfk_1;
ALTER TABLE dubbing DROP CONSTRAINT dubbing_ibfk_3;

DROP TABLE IF EXISTS film_genre;
CREATE TABLE film_genre(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	film BIGINT UNSIGNED,
	genre VARCHAR (150),
	FOREIGN KEY (film) REFERENCES films(id)	
); 

INSERT INTO film_genre (film, genre)
VALUES 
-- Добавляем жанры в одну строчку
(1,CONCAT((SELECT name FROM genres WHERE id = 30),',',' ',(SELECT name FROM genres WHERE id = 21),',',' ',(SELECT name FROM genres WHERE id = 9)));
INSERT INTO film_genre (film, genre)
VALUES
(2,CONCAT((SELECT name FROM genres WHERE id = 28),',',' ',(SELECT name FROM genres WHERE id =3),',',' ',(SELECT name FROM genres WHERE id = 26))),
(3,CONCAT((SELECT name FROM genres WHERE id = 11),',',' ',(SELECT name FROM genres WHERE id = 3),',',' ',(SELECT name FROM genres WHERE id = 9),',',' ',(SELECT name FROM genres WHERE id = 21))),
(4,CONCAT((SELECT name FROM genres WHERE id = 12),',',' ',(SELECT name FROM genres WHERE id = 15))),
(5,CONCAT((SELECT name FROM genres WHERE id = 18),',',' ',(SELECT name FROM genres WHERE id = 30),',',' ',(SELECT name FROM genres WHERE id = 12),',',' ',(SELECT name FROM genres WHERE id = 21),',',' ',(SELECT name FROM genres WHERE id = 23))),
(6,CONCAT((SELECT name FROM genres WHERE id = 16),',',' ',(SELECT name FROM genres WHERE id = 11),',',' ',(SELECT name FROM genres WHERE id = 26),',',' ',(SELECT name FROM genres WHERE id = 9))),
(7,CONCAT((SELECT name FROM genres WHERE id = 28),',',' ',(SELECT name FROM genres WHERE id = 3),',',' ',(SELECT name FROM genres WHERE id = 30),',',' ',(SELECT name FROM genres WHERE id = 21))),
(8,CONCAT((SELECT name FROM genres WHERE id = 28),',',' ',(SELECT name FROM genres WHERE id = 21))),
(9,CONCAT((SELECT name FROM genres WHERE id = 12),',',' ',(SELECT name FROM genres WHERE id = 15))),
(10,CONCAT((SELECT name FROM genres WHERE id = 16),',',' ',(SELECT name FROM genres WHERE id = 12))),
(11,CONCAT((SELECT name FROM genres WHERE id = 26),',',' ',(SELECT name FROM genres WHERE id = 6),',',' ',(SELECT name FROM genres WHERE id = 9),',',' ',(SELECT name FROM genres WHERE id = 3),',',' ',(SELECT name FROM genres WHERE id = 15))),
(12,CONCAT((SELECT name FROM genres WHERE id = 9),',',' ',(SELECT name FROM genres WHERE id = 26),',',' ',(SELECT name FROM genres WHERE id = 12))),
(13,CONCAT((SELECT name FROM genres WHERE id = 9),',',' ',(SELECT name FROM genres WHERE id = 16))),
(14,CONCAT((SELECT name FROM genres WHERE id = 9),',',' ',(SELECT name FROM genres WHERE id = 5),',',' ',(SELECT name FROM genres WHERE id = 11))),
(15,CONCAT((SELECT name FROM genres WHERE id = 15),',',' ',(SELECT name FROM genres WHERE id = 9),',',' ',(SELECT name FROM genres WHERE id = 16))),
(16,CONCAT((SELECT name FROM genres WHERE id = 9))),
(17,CONCAT((SELECT name FROM genres WHERE id = 3),',',' ',(SELECT name FROM genres WHERE id = 26),',',' ',(SELECT name FROM genres WHERE id = 9),',',' ',(SELECT name FROM genres WHERE id = 15))),
(18,CONCAT((SELECT name FROM genres WHERE id = 15),',',' ',(SELECT name FROM genres WHERE id = 9))),
(19,CONCAT((SELECT name FROM genres WHERE id = 18),',',' ',(SELECT name FROM genres WHERE id = 12),',',' ',(SELECT name FROM genres WHERE id = 23),',',' ',(SELECT name FROM genres WHERE id = 21),',',' ',(SELECT name FROM genres WHERE id = 7))),
(20,CONCAT((SELECT name FROM genres WHERE id = 30),',',' ',(SELECT name FROM genres WHERE id = 3),',',' ',(SELECT name FROM genres WHERE id = 21)));

-- Жанр фильма с его именем 
SELECT (SELECT name FROM films WHERE id = film_genre.film),genre FROM film_genre;
TRUNCATE TABLE film_genre;

DROP TABLE IF EXISTS number_of_viewers;
CREATE TABLE number_of_viewers(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	primere date, 
	id_films BIGINT UNSIGNED NOT NULL,
	country VARCHAR(140),
	total VARCHAR (150),
	FOREIGN KEY (id_films) REFERENCES films (id)
);





CREATE TABLE genres(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(45) NOT NULL UNIQUE
);

SELECT * FROM genres;




-- Я не стал создавать отдельно для каждой профессии(сценариста, продюсера и т.д) отдельную таблицуБ потому как это не совсем удобно
-- из-за того, что эти таблицы не смогут ссылаться на таблицу profiles, и пришлось бы созадвать profiles отдельно для каждой профессии...
-- Общий каталог для всех людей имеющих отношение к  производству фильмов удобен еще  и тем, что актер например может быть так же продюсером и режиссером,
-- и у него при этом будет один идентификатор, в то время как один и тот же человек в разных таблицах будет иметь разный айди 
-- (из-за того, что например если я актера захочу добавить в таблицу к режиссерам если актер например еще и режиссер, то появляется трудность добавления к режиссерам человека
-- который никем кроме режиссера не является)... Поэтому в profiles будет отдельно описание профессии для человека(чтобы по описанию из этой таблицы понятно было  кто он такой)
--  а в таблице производтства фильма конкретному человеку будет присвоен идентификатор профессии из каталога профессий... другого способа я не нашел... 
ALTER TABLE person ADD COLUMN lastname VArCHAR (75);
ALTER TABLE person MODIFY  COLUMN lastname VARCHAR(75) NOT NULL;
CREATE TABLE person(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(45) NOT NULL UNIQUE
	lastname VArCHAR (75)
	
);

ALTER TABLE person ADD CONSTRAINT UNIQUE(firstname, lastname);
DROP table IF EXISTS person;
SHOW INDEX FROM person;
ALTER TABLE person add column firstname VARCHAR(45) NOT NULL; 
DESCRIBE person;
ALTER TABLE person ADD COLUMN  lastname VARCHAR (75) NOT NULL ;
ALTER TABLE person MODIFY COLUMN firstname VARCHAR(45) NOT NULL;
SELECT * FROM person ORDER BY id;
INSERT INTO person (firstname, lastname)


INSERT INTO person (firstname, lastname) VALUES
('Александр','Елистратов'),('Рогволд','Суховерко'),('Александр','Рязанцев'),('Геннадий','Карпов'),('Дмитрий','Филимонов'),
('Михаил','Тихонов'),('Валентин','Голубенко'),('Олег','Вирозуб'),('Владимир','Антоник'),('Вадим','Андреев'),
('Сергей','Чихачев'),('Ирина','Киреева'),('Иван','Непомнящий'),('Григорий','Калинин'),('Алексей','Багдасаров'),
('илья','Исаев'),('Юлия','Черкасова'),('Елисей','Никандров'),('Наталья','Сапецкая'),('Илья','Баранов');





DELETE from person WHERE id = 114; 
VALUES
 ('Джеймс', 'Кэмерон'), ('Уильям', 'Уишер мл.'), ('Стефани', 'Остин'),
('Гейл', 'Энн Херд'), ('марио', 'Кассар'), ('Адам', 'Гринберг'), ('Брэд', 'Фидель'), ('Джозеф', 'Немец 3'), ('Джозеф', 'Лаки'), ('Марлен', 'Стюард'), ('Конрад', 'Бафф'), ('Доди', 'Дорн'), ('Марк', 'Голдблатт'), ('Арнольд', 'Шварценеггер'), ('Линда', 'Хэмилтон'), ('Эдвард', 'Ферлонг'),
('Роберт', 'Патрик'), ('Эрл', 'Боэн'), ('Джо', 'Мортон'), ('Ипейта', 'Меркерсон'), ('Кастулло', 'Герра'), ('Дэенни', 'Кукси'), ('Дженнет', 'Голдстин'), ('Ксандер', 'Беркли'), ('Лесли', 'Хэмилтон- Геррен'), ('Кен', 'Гиббел'), ('Роберт', 'Уинли'), ('Питер', 'Шрум'),('Шен', 'Уайлдер'),
('Майкл', 'Эдвардс');

INSERT INTO person (firstname, lastname)
VALUES ('Ридли', 'Скот'), ('Дэвид', 'Францони'), ('Джон', 'Логан'), ('Уильям', 'Николсон'), ('Бранко', 'Лустиг'), ('Дуглас', 'Уик'), ('Лори', 'МакДональд'), ('Терри', 'Нихэм'), ('Уолтер', 'Паркс'), ('Джон', 'Мэтисон'), ('Лиза', 'ДЖерард'), ('Ханс', 'Циммер'),
('Артур', 'Макс'), ('Дженти', 'Йэтс'), ('Криспиан', 'Саллис'), ('Эммилио', 'Ардура'), ('Пьетро', 'Скалия'), ('Рассел', 'Кроу'), ('Хоакин', 'Феникс'), ('Конни', 'Нильсен'), ('Оливер', 'Рид'), ('Ричард', 'Харрис'), ('Дерек ', 'Джекоби'), ('Джимон', 'Хонсу'), ('Дэвид', 'Скофилд'),
('Джон', 'Шрэпнел'), ('Томас', 'Арана'), ('Ральф', 'Мёллер'), ('Спенсер', 'Трит Кларк'), ('Дэвид', 'Хеммингс'), ('Томми', 'Флэнаган');

INSERT INTO person (firstname, lastname) VALUES 
('Леонид', 'Гайдай'), ('Яков', 'Костюковский'), ('Морис', 'Слободской'), ('Аркадий', 'Ашкинази'), ('Игорь', 'Черных'), ('Александр', 'Зацепин'), ('Феликс', 'Ясюкевич'),
('Валентина', 'Янковская'), ('Юрий', 'Никулин'), ('Андрей', 'Миронов'), ('Анатолий', 'Папанов'), ('Нина', 'Гребенщикова'), ('Станислав', 'Чекан'), ('Владимир', 'Гуляев'), ('Нонна', 'Мордюкова'), ('Светлана', 'Светличная'), ('Роман', 'Филлипов'), ('Григорий', 'Шпигель'), ('Леонид', 'Каневский'), ('Игорь', 'Ясуслович');

INSERT INTO person (firstname, lastname) VALUES 
('Дин', 'Деблуа'), ('Крис', 'Сандерс'), ('Уильям', 'Дэвис'), ('Адам', 'Голдберг'), ('Крессида', 'Коуэлл'), ('Джил', 'Циммерман'), ('Джон', 'Пауэлл'), ('Кэтти', 'Алтери'), ('Пьер-Оливье', 'Винсент'), ('Марриан', 'Брэндон'), ('Даррен', 'Т. Холмс'), ('Джей', 'Барушель'), ('Джерард', 'Батлер'),
('Крэйг', 'Фергюсон'), ('Америка', 'Феррера'), ('Джона', 'Хилл'), ('Кристофер', 'Минц-Плассе'), ('Тиджей', 'Миллер'), ('Кристен', 'Уиг'), ('Филип', 'МакГреейд'), ('Кирон', 'Эллиот'), ('Эшли', 'Дженсен'), ('Дэвид', 'Тэннант');
INSERT INTO person (firstname, lastname) VALUES 
('Джон', 'Ландау'), ('Памела', 'Исли'), ('Эл', 'Гиддингс'),
('Грант', 'Хилл'), ('Шэррон', 'Манн'), ('Рэй', 'Сэнчини'), ('Рассел', 'Карпентер'), ('Джеймс', 'Хорнер'), ('Питер', 'Ламонт'), ('Мартин', 'Лэён'), ('Чарльз', 'Дуйт Ли'), ('Дебора ', 'Линн Скот'), ('Майкл', 'Форд'), ('Леонардо', 'Дикаприо'), ('Кейт', 'Уинслейт'), ('Билли', 'Зейн'),
('Кэти', 'Бейтс'), ('Фрэнсис', 'Фишер'), ('Глория', 'Стюард'), ('Билл', 'Пэкстон'), ('Бернард', 'Хилл'), ('Дэвид', 'Уорнер'), ('Виктор', 'Гарбер'), ('Джонатан', 'Хайд'), ('Сьюзии', 'Эймис'), ('Льюис', 'Абернати'), ('Йоан', 'Гриффит'), ('Ричард', 'Грэм');
INSERT INTO person (firstname, lastname) VALUES
('Джос', 'Уидон'),
('Зак', 'Пенн'), ('Кевин', 'Файги'), ('Виктория', 'Алонсо'), ('Луис', 'Д’Эспозито'), ('Джон', 'Фавро'), ('Алан', 'Файн'), ('Джереми', 'Латчем'), ('Стэн', 'Ли'), ('Патриция', 'Уитчер'), ('Шеймас', 'МакГарви'), ('Алан', 'Силвестри'), ('Джеймс', 'Чинланд'), ('Бенжамин', 'Эдельберг'),
('Янн', 'Энджел'), ('Александра', 'Бирн'), ('Виктор Дж.', 'Золфо'), ('Джеффри', 'Форд'), ('Лиза', 'Лэссек'), ('Роберт', 'Дауни мл.'), ('Крис', 'Эванс'), ('Крис', 'Хэмсворт'), ('Скарлетт', 'Йохансон'), ('Джереми', 'Реннер'), ('Том', 'Хидлстон'), ('Сэмюэль Л.', 'Джексон'), ('Кларг', 'Грегг'),
('Коби', 'Смолдерс'), ('Гвинет', 'Пэлтроу'), ('Пол', 'Беттани');
INSERT INTO person (firstname, lastname) VALUES
('Стэнли', 'Кубрик'), ('Артур', 'Чю Кларк'), ('Виктор', 'Линдон'), ('Джеффри', 'Ансуорт'), ('Эрнест', 'Арчер'), ('Гарри', 'Ланж'), ('Энтони', 'Мастерс'), ('Джон', 'Хёсли'), ('Харди', 'Эмис'), ('Роберт', 'Картрайт'),
('Рэй', 'Лавджой'), ('Кир', 'Дулеа'), ('Гэри', 'Локвуд'), ('Уильям', 'Сильвестр'), ('Дэниэль', 'Риктер'), ('Леонард','Росситер'), ('Маргарет', 'Тайзек'), ('Роберт', 'Битти'), ('Шон', 'Салливан'), ('Дуглас', 'Рэйн');

INSERT INTO person (firstname, lastname) VALUES
('Франсис', 'Вебер'), ('Жерар', 'Депардье'), ('Пьер', 'Ришар'),
('Клод', 'Агостини'), ('Владимир', 'Косма'), ('Жерар', 'Даудаль'), ('Коррин', 'Жорри'), ('Манти-Софи', 'Дюбю'), ('Стефан', 'Бьерри'), ('Анни', 'Дюлере'), ('Мишель', 'Омон'), ('Жан-Жак', 'Шеффер'), ('Филипп', 'Хорсан'), ('Ролан', 'Бланш'), ('Жак', 'Франц'), ('Морис', 'Барье');

INSERT INTO person (firstname, lastname) VALUES
('Франко', 'Кастеллано'), ('Джузеппе', 'Моччиа'), ('Уильям', 'Шекспир'), ('Марио', 'Чекки Горри'), ('Витторио', 'Чекки Горри'), ('Альфио', 'Контини'), ('Детто', 'Мариано'), ('Бруно', 'Амальфитано'), ('Уэйн', 'А. Финклеман'), ('Антонио', 'Сичильяно'), ('Адриано', 'Челентано'), ('Орнелла', 'Мути'), ('Эдит', 'Питерс'),
('Пиппо', 'Сантонастасо'), ('Милли', 'Калуччи'), ('Сандро', 'Гиани'), ('Николя', 'Дель БУоно');

INSERT INTO person (firstname, lastname) VALUES
('Пак', 'Чхан-ук'), ('Лим', 'Джун-хён'), ('Хван', 'Джо-юн'), ('Ким', 'Дон-джу'), ('Сид', 'Лим'), ('Чи', 'Ён-джун'), ('Хан', 'Джэ-док'), ('Чо', 'Ён-ук'), ('Ли', 'Джи-су'),
('Рю', 'Сон-чи'), ('У', 'Сын-ми'), ('Чо', 'Сан-гён'), ('Ким', 'Сан-бом'), ('Ким', 'Джэ--бом'), ('Чве', 'Мин-сик'), ('Ю', 'Джи-тхэ'), ('Кан', 'Хен-джон'), ('Ким', 'Бён-ок'), ('О', 'Даль-су'), ('Чи', 'Дэ-хан'), ('Ли', 'Сын-щин'), ('Юн', 'Джин-со'),
('Ли', 'Дэ-ён'), ('О', 'Гван-ок'), ('О', 'Тхэ-гён'), ('Ю', 'Ён-сок');

INSERT INTO person (firstname, lastname) VALUES
('Пон', 'Джун-хо'), ('Хан', 'Джин-вон'), ('Квак', 'Щин-э'), ('Мун', 'Ян-гвон'), ('Мики', 'Ли'), ('Хо', 'Мин-хве'), ('Чан', 'Ён-хван'), ('Хон', 'Гён-пхё'), ('Чон', 'Джэ-иль'),
('Ли', 'Ха-джун'), ('Чхве', 'Сэ-ён'), ('Ян', 'Джин-мо'), ('Сон', 'Кан-хо'), ('Ли', 'Сон-гюн'), ('Чо', 'Ё-джон'), ('Чхве', 'у-щик'), ('Пак', 'Со-дам'), ('Чан', 'Хе-джин'), ('Чон', 'Джи-со'), ('Чон', 'Хё-джун'), ('Ли', 'Джон-ын'), ('Пак', 'Со-джун'),
('Ко', 'Гван-джэ'), ('Ли', 'Щи-хун'), ('Чон', 'И-со');

INSERT INTO person (firstname, lastname) VALUES
('Алехандро', 'Гонсалес Иньяритту'), ('Армандо', 'Бо'), ('Николас', 'Джакобоне'), ('Фернандо', 'Бовайра'), ('Джон', 'Килик'), ('Альфонсо', 'Куарон'), ('Гильермо', 'дель Торо'), ('Сандра', 'Эрмида'), ('Дэвид', 'Линд'), ('Эдмон', 'Рош'),
('Родриго', 'Прието'), ('Густаво', 'Сантаолалья'), ('Бригитта', 'Брох'), ('Марина', 'Позанко'), ('Сильвия', 'Штейнбрехт'), ('Сабина', 'Дайгелер'), ('Пако', 'Дельгадо'), ('Ллуиза', 'Фере'), ('Стивен', 'Миррионе'), ('Хавьер', 'Бардем'), ('Марисель', 'Альварес'), ('Ханна', 'Бушаиб'), ('Гильермо', 'Эстрелья'),
('Эдуард', 'Фернандес'), ('Шейх', 'Ндиае'), ('Диарьяту', 'Дафф'), ('Чэнь', 'Тайшень'), ('Ло', 'Цзинь'), ('Джордж', 'Чибуиквем Чуквум'); 


INSERT INTO person (firstname, lastname) VALUES
('никита', 'Михалков'), ('Рустам', 'Ибрагимбеков'), ('Николь', 'Канн'), ('Жан-Луи', 'Пьел'), ('Владимир', 'Седов'), ('Мишель', 'Сейду'), ('Леонид', 'Верещагин'),
('Вилен', 'Калюта'), ('Эдуард', 'Артемьев'), ('Дмитрий', 'Атовмян'), ('Владимир', 'Аронин'), ('Александр', 'Самулекин'), ('Наталья', 'Иванова'), ('Энцо', 'Меникони'), ('Олег', 'Меньшиков'), ('Ингеборга', 'Дапкунайте'), ('Надежда', 'Михалкова'), ('Андре', 'Усмански'), ('Вячеслав', 'Тихонов'), ('Светлана', 'Крючкова'),
('Владимр', 'Ильин'), ('Алла', 'Казанская'), ('Нина', 'Архипова'); 

INSERT INTO person (firstname, lastname) VALUES
('Дэнни', 'Бойл'), ('Лавлин', 'Тандан'), ('Саймон', 'Бофой'), ('Викас', 'Сваруп'), ('Кристиан', 'Колсон'), ('Франсуа', 'Ивернель'), ('Ивана', 'МакКинон'), ('Камерон', 'МакКрекен'), ('Табрез', 'Нурани'), ('Пол', 'Ричи'),
('Тесса', 'Росс'), ('Пол', 'Смит'), ('Энтони', 'Дод Мэнтл'), ('А.', 'Рахман'), ('Марк', 'Дигби'), ('Абхидеш', 'Редкар'), ('Рави', 'Шривастав'), ('Крис', 'Дикенс'), ('Дев', 'Патель'), ('Фрида', 'Пинто'), ('Анил', 'Капур'), ('Саурабх', 'Шукла'), ('Махеш', 'Манджрекар'),
('Ирфан', 'кхан'), ('Мадхур', 'Миттал'), ('Радж', 'Зутши'), ('Женева', 'Талвар'), ('Ажаруддин', 'Мохаммед Измаил');


INSERT INTO person (firstname, lastname) VALUES
('Акира', 'Куросава'), ('Масато', 'Идэ'), ('Хидэо', 'Огуни'), ('Рюдзо', 'Кикусима'), ('Сюгоро', 'Ямамото'), ('Томоюки', 'Танака'), ('Асакадзу', 'Накаи'),
('Такао', 'Саито'), ('Масару', 'Сато'), ('Ёсиро', 'Мураки'), ('Ёсико', 'Самэдзима'), ('Тосиро', 'Мифунэ'), ('Юдзо', 'Каяма'), ('Цутому', 'Ямадзаки'), ('Рэйко', 'Дан'), ('Миюки', 'Кувано'), ('Кёко', 'Кагава'), ('Тацуёси', 'Эхара'), ('Тэруми', 'Ники'), ('Акэми', 'Нэгиси'),
('Ёситака', 'Дзуси');


INSERT INTO person (firstname, lastname) VALUES
('Люк', 'Бессон'), ('Клод', 'Бессон'), ('Джон', 'Гарлэнд'), ('Бернард', 'Гренет'), ('Тьерри', 'Арбогаст'), ('Эрик', 'Серра'), ('Дэн', 'Веёл'), ('Жеран', 'Дролон'), ('Магали', 'Гвидаси'), ('Франсуаз', 'Бенуа-Фреско'), ('Сильви', 'Ландра'), ('Жан', 'Рено'),
('Натали', 'Портман'), ('Гари', 'Олдман'), ('Дэнни', 'Айелло'), ('Питер', 'Эппел'), ('Уилли', 'Уан Блад'), ('Дон', 'Крич'), ('Кит', 'А. Гласко'), ('Рэндольф', 'Скотт'), ('Майкл', 'Бадаллуко');


INSERT INTO person (firstname, lastname) VALUES
('Квентин', 'Тарантино'), ('Роджер', 'Эвери'), ('Лоуренс', 'Бендер'), ('Дэнни', 'ДеВито'),
('Ричард', 'Н. Гладштейн'), ('Майкл', 'Шамберг'), ('Стейси', 'Шер'), ('Анджей', 'Секула'), ('Дэвид', 'Уоско'), ('Чарльз', 'Колам'), ('Бетси', 'Хайман'), ('Сэнди', 'Рейнольдс-Уоско'), ('Салли', 'Менке'), ('Джон', 'Траволта'), ('Брюс', 'Уиллис'), ('Ума', 'Турман'),
('Винг', 'Реймз'), ('Тим', 'Рот'), ('Харви', 'Кейтель'), ('Питер', 'Грин'), ('Аманда', 'Пламмер'), ('Стив', 'Бушеми'), ('Кристофер', 'Уокен'); 

INSERT INTO person (firstname, lastname) VALUES
('Вячеслав', 'Котеночкин'), ('Юрий', 'Бутырин'), ('Владимир', 'Тарасов'), ('Феликс', 'Камов'), ('Аркадий', 'Хайт'), ('Александр', 'Курляндский'),
('Светлана', 'Кащеева'), ('Нина', 'Климова'), ('Елена', 'Петрова'), ('Александр', 'Чеховский'), ('Виктор', 'Бабушкин'),('Андрей', 'Державин'), ('Светозар', 'Русаков'), ('Алексей', 'Котёночкин'), ('Светлана', 'Давыдова'), ('Дарья', 'Брежнева'), ('Маргарита', 'Михеева'), ('Татьяна', 'Сазонова'),
('Клара', 'Румянова'), ('Геннадий', 'Хазанов'), ('Владимир', 'Сошальский'), ('Игорь', 'Христенко'), ('Ольга', 'Зверева');

INSERT INTO person (firstname, lastname) VALUES
('Гор', 'Вербински'), ('Тед', 'Эллиот'), ('Терри', 'Россио'), ('Стюард', 'Битти'), ('Джей', 'Уолптер'), ('Дариуш', 'Вольски'), ('Клаус', 'Бадельт'),
('Брайан', 'Моррис'), ('Дерек', 'Р. Хилл'), ('Майкл', 'Пауэлс'), ('Пенни', 'Роуз'), ('Ларрис', 'Диас'), ('Стивен', 'Е. Ривкин'), ('Артур', 'Шмидт'), ('Крэйг', 'Вуд'), ('Джонни', 'Депп'), ('Джеффри', 'Раш'), ('Кира', 'Найтли'), ('Джек', 'Девенпорт'),
('Кевин', 'МакНэлли'), ('Джонатан', 'Прайс'), ('Ли', 'Аренберг'), ('Макензи', 'Крук'), ('Дэвид', 'Бэйли');

INSERT INTO person (id, firstname, lastname) VALUES
(90,'Чон', 'Дон-джу'), (91,'Чу', 'Сон-мин'), (92,'Ю', 'Ок');
INSERT INTO person (id, firstname, lastname) VALUES
(93,'Джерри','Брукхаймер');
('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),
('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''), ('', ''),

SELECT * FROM person ORDER by id;

DROP TABLE IF EXISTS about_person;

CREATE TABLE about_person(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	person BIGINT UNSIGNED NOT NULL,
	about_person TEXT,
	FOREIGN KEY (person) REFERENCES person (id)
);

INSERT INTO about_person (person, about_person) VALUES 
(113,'Брат продюсера Боба Вайнштейна.'),
(113,'Был удостоен Ордена Почетного легиона (Франция) 7 марта 2012 года за весомый вклад в киноиндустрию.'),
(113,'Харви вырос в еврейской семье, а его бабушка и дедушка по материнской линии — выходцы из Польши.'),
(113,'В 1979 году Харви и его брат Боб основали кинокомпанию Miramax Films, а в 2005-м – The Weinstein Company.'),
(101,'Питер Джексон и Фрэн Уолш 2 марта 2002 года стали кавалерами новозеландского ордена «За Заслуги».'),
(101,'Питер Джексон (как, кстати, и Альфред Хичкок) традиционно снимается в своих фильмах в какой-нибудь эпизодической роли.'),
(101,'Питер Джексон коллекционирует модели самолётов времен Первой мировой войны.'),
(101,'С 2002 года Питер Джексон значится в списке самых влиятельных лиц киноиндустрии, ежегодно публикуемых журналом Premiere. В 2002 году он был в списке 41-м, в 2003 году — 20-м, в 2004 году — 6-м, а в 2005 году возглавил этот список на 1-м месте.'),
(101,'У Питера Джексона и Фрэн Уолш двое детей — Билли Джексон и Кэти Джексон.'),
(101,'После фильма «Властелин колец: Братство кольца» (2001) восемь из девяти членов Братства сделали себе татуировку в виде эльфийского символа «9». Джексон также сделал себе татуировку в виде эльфийского символа «10».'),
(262,'Разбился на турбовинтовом двухместном учебно-тренировочном военном самолёте Embraer EMB S312 Tucano (английской модификации Short) в 60 милях к северу от Санта-Барбары, в национальном лесу Лос-Падрес. На борту самолёта он был один.'),
(220,'Полное имя — Никулин Юрий Владимирович.'),
(220,'Служил в Красной Армии с 1939 по 1946, пройдя «зимнюю» советско-финскую и Великую отечественную войну. После окончания войны пытался поступить во ВГИК и другие театральные институты, куда его не приняли, так как комиссии не обнаруживали в нем актерских способностей. В конце концов, поступил в студию клоунады при Московском цирке на Цветном бульваре.'),
(220,'Вел юмористическую передачу «Белый попугай», являлся одним из постоянных участников передачи «В нашу гавань заходили корабли».'),
(220,'Народный артист СССР (1973).'),
(220,'Герой Социалистического Труда (1990).'),
(220,'Кавалер Ордена «За заслуги перед Отечеством» III степени (1996).'),
(220,'Похоронен 26 августа на Новодевичьем кладбище столицы, участок № 5, ряд № 23а, место № 5.'),
(220,'Скончался после операции на сердце.'),
(268, 'Полное имя — Леонардо Вильгельм ДиКаприо (Leonardo Wilhelm DiCaprio).'),
(268, 'Леонардо ДиКаприо родился в семье хиппи и вырос в одном из самых опасных пригородов Лос-Анджелеса.'),
(268, 'Когда Лео было всего 2,5 года, отец отвел его на популярное детское телешоу — это стало первым появлением будущего актера перед камерой.'),
(268, 'Родители ДиКаприо — Джордж (автор комиксов) и Ирмелин (работавшая социальным служащим) развелись, когда ему ещё не исполнился один год, однако в дальнейшем старались воспитывать его по возможности вместе, чтобы не лишать ни отцовской, ни материнской заботы.'),
(268, 'Мать Лео выбрала ему столь необычное имя, когда ещё не родившийся сын толкнулся в ней, когда она рассматривала картину Леонардо да Винчи.'),
(268, 'В 1997 году был включен в список 50 самых красивых людей мира по версии журнала People.'),
(268, 'Учился в John Marshall High School в Лос-Анджелесе (Калифорния).'),
(268, 'Когда актеру было 10 лет, его агент предложил ему сменить имя на более дружелюбное и более американское — Ленни Уильямс.'),
(268, 'Отец ДиКаприо происходит из семьи с итало-немецкими корнями. Мать ДиКаприо, Ирмелин ДиКаприо, в девичестве Инденбиркен, родилась в западногерманском Ор-Эркеншвике. Её отцом был Вильхельм Инденбиркен, а матерью — русская Елена Смирнова, которая после переезда в Германию из России вышла замуж и приняла фамилию мужа — Инденбиркен. Сам же ДиКаприо в разговоре с Владимиром Путиным сообщил, что его дед также был русским, и добавил: «Так что я не на четверть, а наполовину русский».'),
(268, '16 сентября 2014 года ДиКаприо был избран посланником мира ООН по проблемам климата.'),
(268, 'В ноябре 2013 года ДиКаприо внес три миллиона долларов во Всемирный фонд дикой природы для сохранения и приумножения популяции тигров в Непале.'),
(268, 'В 2013 году актер стал совладельцем гоночной команды Venturi Grand Prix Formula E Team для участия в Формуле-Е.'),
(308,'Полное имя — Сэмюэл Лерой Джексон (Samuel Leroy Jackson).'),
(308,'Детство провел в городе Чатнуга, штате Теннесси. Отец покинул семью, и маленького Сэма воспитали мать и бабушка с дедом.'),
(308,'У актёра есть дочь Зои (1982 г.р.). Она работает продюсером спортивного канала.'),
(308,'После школы он поступил в частный мужской Morehouse College в Атланте на факультет архитектуры. С детства Сэмюэл боролся с заиканием. Он посещал врача колледжа, а также брал уроки учителя музыки. За старания Джексона перевели на факультет драмы.'),
(308,'С детства и по сей день борется с заиканием. В итоге, научился «имитировать» тех кто не заикается, используя аффирмацию — слово «motherfucker».'),
(423,'Полное имя — Гильермо дель Торо Гомес.'),
(423,'Проходил обучение в Институте Наук.'),
(423,'В 1997 году похитили его отца и удерживали 72 дня, пока не получили выкуп. После чего Гильермо перебрался с семьей в Америку в качестве экспатрианта.'),
(519,'Окончил школу западного рисования Doshusha.'),
(519,'Родился в семье потомственного самурая и был самым младшим ребёнком в семье, где помимо него росло ещё шестеро детей — три сестры и три брата.'),
(519,'Указом Президента СССР № УП-1605 от 12 марта 1991 года награждён орденом Дружбы народов «за большой личный вклад в развитие культурных связей между Советским Союзом и Японией».'),
(530,'Настоящее имя — Саньчуань Миньлан (Sanchuan Minlang).'),
(530,'Тосиро родился, когда его родители работали на оккупированной японцами территории Китая. Там он вырос и получил образование.'),
(530,'Его сыновья — актёр и продюсер Сиро Мифунэ и Такэси Мифунэ (Takeshi Mifune).'),
(530,'Его дочь — актриса Мика Мифунэ от связи с актрисой Микой Китагавой.'),
(530,'Его внук — актёр Рикия Мифунэ.'),
(675, 'Многие ошибочно считают что Заяц из «Ну, погоди!» был озвучен Надеждой Румянцевой, на самом деле Зайца озвучила Румянова.'),
(675, 'Единственная актриса, удостоенная почётного звания «Заслуженный артист РСФСР за работу в мультипликации».'),
(675, 'Окончила ВГИК — актерский факультет (мастерская С.Герасимова и Т.Макаровой).'),
(675, 'Заслуженная артистка России.'),
(675, 'Скончалась от рака молочной железы.'),
(720,'Полное имя — Джон Кристофер Депп II (John Cristopher Depp II).'),
(720,'В венах актера течет кровь индейцев чероки, ирландцев и немцев.'),
(720,'Отец Джонни работал городским инженером, а его мать — официанткой; у него две старшие сестры — Дебби и Кристи, и старший брат Дэниэл, который стал писателем.'),
(720,'В детстве актер очень много переезжал и, по его словам, к 15 годам успел сменить около 20, а то и больше, мест жительства. Все дело было в том, что его мать очень любила менять обстановку.'),
(720,'Родители Джонни Деппа развелись, когда ему было 16 лет.'),
(720,'В детстве у него была аллергия на шоколад.'),
(720,'Будучи ребенком, Джонни постоянно терпел издевательства сверстников, которые обзывали его Джонни Дип (от «dippy» — тронутый).'),
(359,'Был пятым ребенком в семье, переехавшей из Апулии на север в поисках работы.'),
(359,'С двенадцати лет Адриано совмещал учёбу с работой подмастерья в часовой мастерской.'),
(359,'Более чем за сорок лет своей творческой деятельности Челентано выпустил свыше 30 музыкальных альбомов общим тиражом 70 миллионов копий.'),
(359,'В честь Адриано Челентано назван астероид № 6697, открытый 24 апреля 1987 года.'),
(359,'От брака с Клаудией Мори у актера трое детей: дочери Розита и Розалинда и сын Джакомо.'),
(335,'Полное имя — Пьер Ришар Морис Шарль Леопольд Дефей (Pierre Richard Maurice Charles Leopold Defay).'),
(335,'Воспитывался в семье своего деда, потомка старинного аристократического рода, который жил на севере Франции. По достижении совершеннолетия Пьер Ришар уехал в Париж, поступать на драматические курсы, против чего выступал его дед. Это послужило поводом для разрыва отношений будущего актёра с семьёй.'),
(335,'Окончил драматические курсы Шарля Дюллена, а затем проходил стажировку у Жана Вилара.'),
(335,'В конце 1980-х годов Пьер Ришар основал свою компанию «Фиделин фильм», занимавшуюся производством и прокатом фильмов, а также выпуском пластинок с песнями самого Пьера Ришара.'),
(335,'Ришар – автор нескольких книг: «Маленький блондин в большом парке» (1989), «Как рыба без воды» (2003), «Почтовые привилегии» (2008). Авторству Пьера Ришара принадлежат также несколько сказок для детей.'),
(460,'После окончания театрального училища в 1981 году поступил в Малый театр. Через год был призван в Советскую армию и проходил службу в Центральном академическом театре Советской армии.'),
(460,'После окончания общеобразовательной и музыкальной школ (1977 год) поступил в Высшее театральное училище им. М.С. Щепкина.'),
(460,'Олег Меньшиков родился в семье военного инженера и врача.'),
(460,'Народный артист России (2003).'),
(460,'Олег Меньшиков учился на курсе у Владимира Монахова.'),
(460,'С 2012 года является художественным руководителем Московского драматического театра имени М. Н. Ермоловой.'),
(380,'Является старшим братом актёра Чхве Гван-иля.'),
(585,'Полное имя — Квентин Джером Тарантино (Quentin Jerome Tarantino).'),
(585,'Родился вне брака у шестнадцатилетней медсестры Конни Макхью от актёра и музыканта Тони Тарантино.'),
(585,'Квентин Тарантино работал в пункте видеопроката, который и послужил ему школой для изучения кино.'),
(585,'У Квентина итальянские, ирландские и корни индейского племени чероки.'),
(585,'Имеет двух сестёр и одного брата.'),
(585,'30 июня 2017 года обручился с израильской певицей Даниэлой Пик, дочерью известного певца и композитора Цвики Пика, с которой встретился в израильской поездке продвижения «Бесславных ублюдков».'),
(164,'Полное имя — Арнольд Алоис Шварценеггер (Arnold Alois Schwarzenegger).'),
(164,'Арнольд успешно окончил Висконсинский университет по направлению «Бизнес и экономика» и впоследствии применял полученные знания в губернаторском деле.'),
(164,'Под влиянием своего отца Арнольд начал заниматься футболом, но в возрасте 14 лет предпочёл карьеру культуриста.'),
(164,'В 2002 году в родном городе актера хотели поставить памятник Терминатору. Проект был закрыт по просьбе Арнольда.'),
(164,'В 2004 году, находясь в отпуске на Гавайях, Шварценеггер спас тонущего человека, подплыв к нему и вытащив на берег.'),
(181,'Ридли Скотт является братом известного режиссёра Тони Скотта.'),
(181,'Его дети: Джейк, Люк Скотт и Джордан — стали режиссёрами.'),
(181,'В колледже он снял свой первый фильм — короткометражку «Парень и велосипед», где главные роли играли его отец и младший брат. После окончания колледжа он поступил на работу в Би-би-си, где сначала выполнял обязанности дизайнера в телесериалах.'),
(181,'Отец Ридли Скотта был армейским офицером, мать Элизабет Скотт — актрисой. Его старший брат Фрэнк поступил на службу в Британский торговый флот, когда Ридли был ещё маленький, и они редко виделись. Семья Скоттов часто переезжала, они жили в Камбрии, Уэльсе, Германии. В 1944 году у Ридли появился младший брат Тони, а после войны семья вернулась на северо-восток Англии.'),
(181,'В 1995 году Ридли Скотт вместе с братом Тони основали продюсерскую компанию Scott Free Productions.'),
(181,'После окончания школы он учился на дизайнера в Колледже искусств Вест Харпула, а затем в Королевском колледже искусств в Лондоне (1960—1962).'),
(192,'Полное имя – Ханс Флориан Циммер.'),
(192,'Ханс Циммер признан одним из наиболее инновационных композиторов в киноиндустрии.'),
(192,'До своей сольной карьеры был участником нескольких музыкальных коллективов: Ultravox и The Buggles.'),
(192,'Первый опыт в киномузыке был в соавторстве своего наставника Стенли Майреса в фильме «Моя прекрасная прачечная» (1985).'),
(192,'В течение 80-х и в начале 90-х годов немецкий композитор использовал объединение новых и старых музыкальных технологий – электронная музыка в сочетании традиционной оркестровой.'),
(93,'Полное имя — Джером Леон Брукхаймер (Jerome Leon Bruckheimer).'),
(93,'Джерри Брукхаймер родился в семье еврейских эмигрантов из Германии.'),
(93,'Окончил университет штата Аризона.'),
(304,'У Криса есть братья, Лиам и Люк, которые тоже являются актерами.'),
(304,'11 мая 2012 года у Криса Хемсворта и его жены Эльзы Патаки родилась дочь. Девочку зовут Индия Роуз Хемсворт (India Rose Hemsworth).'),
(304,'18 марта 2014 года у Криса и Эльзы родились двойняшки.');
SELECT id FROM person WHERE  lastname = 'Хэмсворт';

SELECT DISTINCT person, (SELECT CONCAT(firstname, ' ', lastname) FROM person WHERE id = about_person.person) AS name FROM about_person;

-- Количество фильмов, в которых отыграл актер будет выводится через запрос
-- Выводить знак зодиака
SELECT * FROM profession;
DROP TABLE IF EXISTS profiles;
SELECT * FROM profiles;
DESCRIBE profiles;
CREATE TABLE profiles(
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	carrier VARCHAR (155) DEFAULT NULL,
	genre VARCHAR (155) DEFAULT NULL,
	gender ENUM('f', 'm', 'x') NOT NULL,
	height VARCHAR (120) DEFAULT NULL,
	birthday DATE NOT NULL,
	death DATE DEFAULT 0,
	place_of_death VARCHAR(200) DEFAULT 0,
	country_where_dead VARCHAR(200) DEFAULT 0,
	photo_id BIGINT UNSIGNED NOT NULL,
	city VARCHAR(130) DEFAULT 0,
	country VARCHAR(130) DEFAULT 0,
	marital_status VARCHAR (120) DEFAULT NULL,
	amount_of_children INT UNSIGNED,
	FOREIGN KEY (user_id) REFERENCES person (id)
);

SELECT file_name,file_size FROM media;





SELECT * FROM media;
SELECT name FROM films;

INSERT INTO profiles(user_id,photo_id, gender, birthday, city, country, death, place_of_death, country_where_dead)
VALUES 
(113, 1,'m', '1952-03-19','Флашинг, Квинс, Нью-Йорк','США', DEFAULT, DEFAULT, DEFAULT),
(101, 2, 'm','1961-10-31', 'Пукеруа Бэй','Новая Зеландия', DEFAULT, DEFAULT, DEFAULT),
(262, 3, 'm', '1953-08-14', 'Лос-Анджелес, Калифорния,', 'США', '2015-06-22','Санта-Барбара, Калифорния', 'США'),
(220, 4, 'm', '1921-12-18', 'Демидов, Смоленская губерния', 'РСФСР (Россия)', '1997-08-21', 'Москва', 'Россия'),
(268, 5, 'm', '1974-11-11', 'Голливуд, Лос-Анджелес, Калифорния', 'США', DEFAULT, DEFAULT, DEFAULT),
(308, 6, 'm', '1948-12-21', 'Вашингтон, округ Колумбия', 'США', DEFAULT, DEFAULT, DEFAULT),
(423, 7, 'm', '1964-10-09', 'Гвадалахара, Халиско', 'Мексика', DEFAULT, DEFAULT, DEFAULT),
(519, 8, 'm', '1910-03-10',  'Токио', 'Японская империя (Япония)', '1998-09-10', 'Токио', 'Япония'),
(530, 9, 'm', '1920-04-01', 'Циндао, Шаньдун', 'Японская империя (Китай)', '1997-12-24', 'Токио', 'Япония'),
(675, 10,'f', '1929-12-04', 'Ленинград', 'СССР (Санкт-Петербург, Россия)', '2004-09-18', 'Москва', 'Россия'),
(720, 11, 'm', '1963-06-09', 'Оуэнсборо, Кентукки', 'США', DEFAULT, DEFAULT, DEFAULT),
(359, 12, 'm', '1938-01-06', 'Милан', 'Королевство Италия (Италия)', DEFAULT, DEFAULT, DEFAULT),
(335, 13, 'm', '1934-09-16', 'Валансьен, Нор', 'Франция', DEFAULT, DEFAULT, DEFAULT),
(460, 14, 'm', '1960-11-08', 'Серпухов, Московская область', 'СССР (Россия)', DEFAULT, DEFAULT, DEFAULT),
(380, 15, 'm', '1962-05-30', 'Сеул', 'Южная Корея', DEFAULT, DEFAULT, DEFAULT),
(304, 16, 'm', '1983-08-11', 'Мельбурн, Виктория', 'Австралия', DEFAULT, DEFAULT, DEFAULT),
(192, 17, 'm', '1957-09-12', 'Франкфурт-на-Майне', 'ФРГ (Германия)', DEFAULT, DEFAULT, DEFAULT),
(164, 18, 'm', '1947-07-30', 'Таль, Грац', 'Австрия', DEFAULT, DEFAULT, DEFAULT),
(181, 19, 'm', '1937-11-30', 'Саут-Шилдс, Англия', 'Великобритания', DEFAULT, DEFAULT, DEFAULT), 
(585, 20, 'm', '1963-03-27', 'Ноксвилл, Теннесси', 'США', DEFAULT, DEFAULT, DEFAULT); 
truncate table profiles;
SELECT user_id,(SELECT CONCAT(firstname, ' ', lastname) FROM person WHERE id = profiles.user_id) AS name,carrier, genre, height, amount_of_children, marital_status FROM profiles;
SELECT * FROM profiles;


ALTER TABLE sites MODIFY COLUMN adress TEXT;
SELECT * FROM sites;
DROP TABLE IF EXISTS sites;
CREATE TABLE sites(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	person BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (person) REFERENCES person(id)
);


SELECT about_person FROM about_person WHERE person = 268;

INSERT INTO sites (person, adress) VALUES 
(93, NULL),
(101,'https://www.facebook.com/PeterJacksonNZ/,http://tbhl.theonering.net/'),
(113, NULL), (220, NULL),
(164, 'http://schwarzarnold.ucoz.ru/, http://steelhero.ru/, https://twitter.com/Schwarzenegger, https://facebook.com/arnold
http://www.schwarzenegger.it/, http://instagram.com/schwarzenegger, http://www.joinarnold.com/, http://thearnoldfans.com'),
(181,'http://www.ridleyscott.ru/'),
(192, 'https://twitter.com/HansZimmer, http://www.hans-zimmer.ch/сообщить о неработающей ссылке, http://www.hans-zimmer.com,
http://www.myspace.com/149325167, http://instagram.com/hanszimmer, http://www.hanszimmer.com/'),
(268, 'http://l-dicaprio.narod.ru/, http://www.dicaprioleonardo.forum24.ru/, https://twitter.com/LeoDiCaprio, http://facebook.com/LeonardoDiCaprio,
http://www.leonardodicaprio.org/,http://simplyleonardodicaprio.com/, http://instagram.com/leonardodicaprio,
http://www.leonardo-dicaprio.com/, http://www.dicaprio.com/,
http://www.myspace.com/leonardodicaprio, http://www.leonardodicaprio.com/, http://www.heartofdestiny.com/, http://leonardo.hollywood.com/'),
(304,'ttps://twitter.com/chrishemsworth, https://www.facebook.com/chrishemsworth/,
http://www.chrishemsworth.org/, http://instagram.com/chrishemsworth'),
(308, NULL),
(335, 'http://pierre-richard.ru/, http://www.pierre-richard.fr/'),
(359, 'http://www.celentano.ru ,http://ilmondodiadriano.it/blog/
http://www.clancelentano.it/index.php/en/, http://celentano.do.am'),
(380, NULL),
(423,'https://twitter.com/RealGDT, https://facebook.com/REALGDT
http://www.deltorofilms.com/index.php, http://instagram.com/realgdt'),
(460, 'http://www.menshikov.ru/'),
(519, NULL),(530, NULL),
(585, 'http://www.qtarantino.ru/, http://www.tarantino.info/,
http://tarantino.ucoz.com/, http://everythingtarantino.com/, http://tarantinoitalia.altervista.org/'),
(675, NULL),
(720, 'http://www.johnnydeppfan.ru/,http://www.johnnydepp.ru/, http://www.depplovers.com.br/,
http://www.deppimpact.com/ ,http://www.johnny-depp.org/, http://johnnydeppweb.com/, http://www.johnnydepp-zone.com/');


DROP TABLE IF EXISTS name_of_professions;


CREATE TABLE profession_name(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(45) NOT NULL UNIQUE
);

 
INSERT INTO profession_name(name)
VALUES('Ассоциативный продюсер'),
('Сопродюсер'),
('Художник по костюмам'),
('Художник по декорациям')
;

INSERT INTO profession_name(name)
VALUES ('Линейный продюсер');

SELECT * FROM profession_name ORDER BY id;












-- Награды (оскар)
DROP TABLE catalog_of_nomination_for_picture;
CREATE TABLE catalog_of_nomination_for_picture(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR (150)	
);
truncate TABLE catalog_of_nomination_for_picture; 
INSERT INTO catalog_of_nomination_for_picture VALUES
(1,'Лучший фильм года'),
(2,'Лучший анимационный полнометражный фильм'),
(3,'Лучший анимационный короткометражный фильм'),	
(4,'Лучший художественный короткометражный фильм'),
(5,'Лучший документальный полнометражный фильм'),	
(6,'Лучший документальный короткометражный фильм'),
(7,'Лучший фильм на иностранном языке'),
(8,'Лучший оригинальный сценарий'),
(9,'Лучший сценарий-адаптация'),
(10,'Лучшая операторская работа'),
(11, 'Лучшие декорации'),
(12, 'Лучшие костюмы'),
(13,'Лучший звук'),
(14,'Лучший монтаж'),
(15, 'Лучший грим'),
(16,'Лучшая песня'),
(17,'Лучшая оригинальный саундтрек');



SELECT * FROM catalog_of_nomination_for_picture;

DROP TABLE IF EXISTS catalog_of_nomination_for_person;
CREATE TABLE catalog_of_nomination_for_person(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR (150)	
);

SELECT id,name FROM films;
INSERT INTO catalog_of_nomination_for_person VALUES
(1,'Лучшая режиссура'),
(2,'Лучшая мужская роль'),
(3,'Лучшая мужская роль второго плана')	,
(4,'Лучшая женская роль'),
(5,'Лучшая женская роль второго плана'),
(6, 'Почетный оскар');


SELECT * FROM catalog_of_nomination_for_person confp;

Drop TABLE oscar_for_picture;
CREATE TABLE oscar_for_picture (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nomination BIGINT UNSIGNED NOT NULL,
	year_ YEAR,
	nominees BIGINT UNSIGNED NOT NULL,
	got BOOLEAN DEFAULT FALSE,
	FOREIGN KEY (nominees) REFERENCES films (id),
	FOREIGN KEY (nomination) REFERENCES catalog_of_nomination_for_picture(id)
);

SELECT * FROM oscar_for_picture;

INSERT INTO oscar_for_picture(year_, nomination, nominees, got) values
(2002, 1, 1, 0),
(2002, 1, 21, 0),
(2002, 1, 22, 1),
(2002, 1, 23, 0),
(2002, 1, 24, 0);
SELECT id,name FROM films;
INSERT INTO oscar_for_picture(year_, nomination, nominees, got) VALUES
(2002, 15, 1, 1),
(2002, 15, 21, 0),
(2002, 15, 22, 0);


INSERT INTO oscar_for_picture(year_, nomination, nominees, got) VALUES
(2002,17, 1, 1),
(2002, 17,25, 0),
(2002, 17,26, 0),
(2002, 17,27,0),
(2002,17,22, 0);

INSERT INTO oscar_for_picture(year_, nomination, nominees, got) VALUES
(1997,1,6,1),
(1997,1,28,0),
(1997,1,29,0),
(1997,1,30,0),
(1997,1,31,0);

INSERT INTO oscar_for_picture(year_, nomination, nominees, got) VALUES
(1998,10,6,1),
(1998,10,32,0),
(1998,10,30,0),
(1998,10,33,0),
(1998,10,34,0);



SELECT id,name FROM films;
INSERT INTO films (id,name) VALUES
(25, 'Корпорация монстров'),
(26,'Искусственный разум'),
(27,'Гарри Поттер и философский камень');
SELECT id,name FROM films;
INSERT INTO films (id,name) VALUES
(28,'Мужской стриптиз'),
(29,'Умница Уилл Хантинг'),
(30,'Секреты Лос-Анджелеса'),
(31,'Лучше не бывает');
INSERT INTO films (id,name) VALUES
(32,'Амистад'),
(33,'Кундун'),
(34,'Крылья голубки');
(,''),
INSERT INTO oscar_for_picture(n) VALUES 


DROP TABLE IF EXISTS oscar_for_person;
ALTER TABLE oscar_for_person  DROP CONSTRAINT oscar_for_person_ibfk_1;
CREATE TABLE oscar_for_person(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	nomination BIGINT UNSIGNED,
	nominees_person BIGINT UNSIGNED,
	film  BIGINT UNSIGNED NOT NULL,
	year_ YEAR,
	got BOOLEAN DEFAULT FALSE,
	FOREIGN KEY(nominees_person) REFERENCES person (id),
	FOREIGN KEY (nomination) REFERENCES catalog_of_nomination_for_person(id)
);


SELECT (SELECT name FROM catalog_of_nomination_for_person confp WHERE id oscar_for_person,nomination) FROM oscar_for_person ofp  WHERE nominees_person = (SELECT )
SELECT id FROM person WHERE firstname= 'Кейт' AND lastname='Бланшет';
SELECT * FROM films;
SELECT * FROM oscar_for_person ofp;
-- Добавляем номинантов на лучшую режиссуру
INSERT INTO oscar_for_person(year_,nomination, nominees_person, film, got)
VALUES 
(2009,1,469,15,1),
(2009,1,70,35,0),
(2009,1,71,36,0),
(2009,1,72,37,0),
(2009,1,73,38,0);

-- Добавляем номинантов на лучшую мужскую роль
INSERT INTO oscar_for_person(year_,nomination, nominees_person, film, got)
VALUES
(2001,2,198,3,1),
(2001,2,74,39,0),
(2001,2,721,40,0),
(2001,2,75,41,0),
(2001,2,436,42,0);

-- Добавляем номинантов на лучшую женскую роль
INSERT INTO oscar_for_person(year_,nomination, nominees_person, film, got)
VALUES	
(2009,4,179,37,1),
(2009,4,76,43,0),
(2009,4,77,44,0),
(2009,4,78,45,0),
(2009,4,79,46,0);



-- Добавляем номинантов на лучшую женскую роль второго плана
INSERT INTO oscar_for_person(year_,nomination, nominees_person, film, got)
VALUES	
(2007,5,80,47,1),
(2007,5,84,48,0),
(2007,5,81,49,0),
(2007,5,137,50,0),
(2007,5,82,49,0);




INSERT INTO person VALUES
(70,'Дэвид','Финчер'),
(71,'Рон','Ховард'),
(72,'Стивен','Долдри'),
(73,'Гас','Ван Сент');
INSERT INTO person VALUES
(84,'Эбигейл','Бреслин');
INSERT INTO person VALUES
(80,'Дженнифер','Хадсон'),
(81,'Адриана','Барраса'),
(82,'Ринко','Кикути');
('',''),
('','');


INSERT INTO films(name)
VALUES
('Девушка мечты'),
('Маленькая мисс счастье'),
('Вавилон'),
('Скандальный дневник');
(''),
INSERT INTO films(name)
VALUES
('Подмена'),
('Сомнение'),('Замерзшая река'),
('Рейчел выходит замуж');
INSERT INTO films(name)
VALUES
('Загадочная история Беджамина Баттона'),
('Фрост против Никсона'),
('Чтец'),
('Харви Милк');

INSERT INTO films(name)
VALUES
('Изгой'),
('Перо маркиза де Сада'),
('Поллок'),
('Пока не наступит ночь');

(''),
(''),



INSERT INTO person VALUES
(74,'Том','Хэнкс'),
(75,'Эд','Харрис');
INSERT INTO person VALUES
(76,'Анджелина','Джоли'),
(77,'Мэрил','Стрип'),
(78,'Меллиса','Лео'),
(79,'Энн','Хэтуэй');
('',''),




-- MEDIA

CREATE TABLE media_types(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(45) NOT NULL UNIQUE
);

INSERT INTO media_types VALUES (DEFAULT, 'Image');
INSERT INTO media_types VALUES (DEFAULT, 'Document');
INSERT INTO media_types VALUES (DEFAULT, 'Video');
INSERT INTO media_types VALUES (DEFAULT, 'Music');

-- Типы публикаций 
DROP TABLE IF EXISTS types_of_materials;
CREATE TABLE types_of_materials(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(45) 
);

INSERT INTO types_of_materials
VALUES(1,'Выбор редакции'),
(2,'Бюро'),
(3,'Как это смотреть'),
(4,'Эволюция кинообраза'),
(5,'нет'),
(6,'Сборы');
INSERT INTO types_of_materials
VALUES
(7,'Интервью');
INSERT INTO types_of_materials
VALUES
(8,'Мнение');
INSERT INTO types_of_materials
VALUES
(9,'Сериалы');
INSERT INTO types_of_materials
VALUES
(10,'ОНлайн-кинотеатр');
INSERT INTO types_of_materials
VALUES
(11,'Культовое кино');
(,'');
SELECT *  FROM  types_of_materials tom;
DROP TABLE IF EXISTS media;
-- Добавленные на профиле актера(режиссера и т.д) фото и т.д
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	media_types_id INT UNSIGNED NOT NULL,
	file_name VARCHAR(255),
	file_size BIGINT UNSIGNED,
	added DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES person (id),
	FOREIGN KEY (media_types_id) REFERENCES media_types (id)
);

SELECT firstname,lastname FROM person WHERE id = 436;

INSERT INTO media VALUES
(DEFAULT,268,1,'im.jpg',200,'2011-12-11'),
(DEFAULT,101,1,'jpeg',150, '2017-04-20'),
(DEFAULT,300,1,'im.jpg',175, '2018-02-11'),
(DEFAULT,720,1,'jpeg',168,'2019-11-19'),
(DEFAULT,720,1,'jpeg1',300,'2012-04-25'),
(DEFAULT,268,1,'jpeg 2000',120,'2020-05-01'),
(DEFAULT, 268,1,'jpeg1',105,'2021-11-30'),
(DEFAULT, 269,1,'im.jpg',190,'2020-01-28'),
(DEFAULT,722,1,'im.jpg',174,'2020-06-17'),
(DEFAULT,721,1,'.jfif',197,'2019-08-08' ),
(DEFAULT,436,1,'.jpg',202,'2015-07-30'),
(DEFAULT,480,1,'jpeg XR',1002, '2021-09-11'),
(DEFAULT,320,1,'im31.jpg',189,'2010-02-21'),
(DEFAULT,178,1,'im.jpg',116,'2011-04-22'),
(DEFAULT,200,1,'jpeg',160,'2018-03-01'),
(DEFAULT,240,1,'im311.jpg',111,'2019-01-02'),
(DEFAULT,268,1,'hey.jpg',166,DEFAULT),
(DEFAULT,270,1,'charaster.jpg',153,'2011-09-28'),
(DEFAULT,314,1, 'films,jpg',156,'2013-08-22'),
(DEFAULT,269,1,'age.jpg',172,'2016-11-21'),
(DEFAULT,400,1,'art.jpg',300,'2021-12-30');

SELECT * FROM media WHERE user_id = 268;
SELECT media_types_id, file_name,file_size FROM media;
(person,name_of_post,publication_type,publication_time, body, media_type) VALUES

('')



DROP TABLE IF EXISTS articles;
CREATE TABLE articles(
	id_articles BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	article_title text NOT NULL,
	body TEXT,
	article_type BIGINT UNSIGNED,
	publication_time DATE,
	media_type INT UNSIGNED,
	FOREIGN KEY(article_type) REFERENCES  types_of_materials (id),
	FOREIGN KEY(media_type) REFERENCES  media_types (id)
);

-- Создать представление 'Материалы о персоне'
INSERT INTO articles(article_title, article_type, publication_time, body,media_type) VALUES 
('В прокате — драма Озона об эвтаназии. Советуем 8 фильмов об умирании и рассказываем, зачем их вообще смотреть',5,'2022-01-21',
'В кино можно посмотреть фильм Франсуа Озона «Все прошло хорошо». В центре истории — 85-летний Андре (Андре Дюссолье). После инс
ульта он оказывается парализован и тогда просит дочь (Софи Марсо) помочь ему с эвтаназией. К теме смерти обращался не только Озон
. Мы расспросили психолога, зачем смотреть фильмы о смерти и какие проблемы они помогут выявить. Вдобавок выбрали восемь фильмов, 
где у героев умирает кто-то из близких и они по-разному пытаются это прожить.',2),
('«Карамора»: мыльная опера под маской революции',9, '2022-01-21', '
Первый сериал, снятый Данилой Козловским, наконец-то выходит на платформе Start.
 Актер играет анархиста дореволюционных времен, столкнувшегося с мировым заговором:
 все правящие династии в Европе — вампиры. Насколько удачным получился этот эксперимент с альтернативной историей?',2),
 ('«Гоморра»: как журналист Роберто Савиано превратил книгу о преступности в бандитскую сагу, а потом в блатной романс',9,'2022-01-18',
'В декабре вышел последний эпизод итальянского сериала «Гоморра», посвященного будням участников каморры, неаполитанской организованной преступности.
 Мы вспоминаем, с чего началась эта история и как она пришла к своему финалу.',2),
 ('Богатырь на троне: главные итоги «новогодней битвы» в России', 6, '2022-01-17', 
 'На прошлой неделе в России завершилась «новогодняя битва» — самый кассовый период года,
 который захватывает два последних уик-энда декабря и длинные январские каникулы. Именно
в это время в России устанавливалась львиная доля прокатных рекордов прошлых лет — от «Аватара» 
(3,5 млрд рублей) до «Холопа» (3,069 млрд рублей).',2),
('Каким вышел новый «Крик» — почти нестрашным фильмом, где никого не жалко',5,'2022-01-14', 
'Придуманная Уэсом Крэйвеном хоррор-франшиза в свое время стала каноном постмодернистских ужасов. 
Она породила множество последователей и перебросила мост для жанра из девяностых в нулевые. В 2022-м
 под аплодисменты фанатов ее перезапускают и продолжают одновременно, но кому-то может показаться, что 
страшилка вышла слишком уж пост-пост и мета-мета.', 2),
 ('Фильм недели. «Kings man: Начало». Рэйф Файнс сражается с Распутиным', 5, '2022-01-14',	
 'С неподобающим джентльмену двухгодичным опозданием до экранов добрался приквел шпионской дилогии 
«Kingsman», над которым работал бессменный режиссер франшизы Мэттью Вон. Место Тэрона Эджертона и Ко-
лина Фёрта заняли Харрис Дикинсон и Рэйф Файнс. Фильм переносит зрителей в разгар Первой мировой войны,
 когда и возникла секретная организация. О том, как Мэттью Вон объединил бондиану, мендесовский «1917» и 
исторические факты, устроив бенефис Рэйфу Файнсу, рассказывает Михаил Моркин.',2),
('Кто есть кто в «Этерне»?', 10, '2022-01-14',	
'20 января на Кинопоиске состоится премьера фильма «Этерна: Часть первая». 
Это экранизация российского фэнтези Веры Камши и начало эпичной истории о борьбе
 за власть и корону. Мы уже отвечали на главные вопросы об устройстве мира «Этерны», 
а теперь знакомимся с героями саги и сыгравшими их актерами.',2),
('15 ожидаемых корейских сериалов года', 9, '2022-01-13',
'Начало года всегда ознаменовывается подготовкой плана просмотров на ближайшее будущее.
 Ранее мы уже составляли список самых ожидаемых сериалов 2022-го, но по Южной Корее решили
 пройтись отдельно. Корейские шоу за прошедший год постоянно мелькали в десятке популярных 
на Netflix: «Винченцо», «Приморская деревня Ча Ча Ча», «Зов ада», «Море Спокойствия» и другие
 помогли этому региону заявить о себе. Того и глядишь, что среди перечисленных в материале экземпляров 
затаился тот, кто сможет перебить по популярности «Игру в кальмара».', 2),
('Книга Бобы Фетта»: скучный путь великого мандалорца', 9, '2022-01-13',
'На стриминговом сервисе Disney+ вовсю идет спин-офф «Мандалорца», посвященный Бобе Фетту. 
Марат Шабаев объясняет, почему новый сериал выглядит лишь бледной копией флагманского шоу и
 какое место он занимает в расширяющемся мире «Звездных войн».',2),
 ('Аарон Соркин: «Я хочу, чтобы каждый, кто работает на съемочной площадке, приходил туда с радостью»', 7, '2022-01-12',
 'В конце декабря на стриминге Amazon Prime Video вышел новый фильм Аарона Соркина «В роли Рикардо». Это биографическая драма,
 в которой Николь Кидман и Хавьер Бардем сыграли главных звезд послевоенного американского телевидения Люсиль Болл и ее супруга
, актера и продюсера Дези Арназа. Вместе они снимались в роли супругов Люси и Рики Рикардо в самом успешном американском ситкоме 
«Я люблю Люси». Важные события из жизни этой пары Соркин уместил в жесткие временные рамки одной недели — именно столько снимался каждый эпизод шоу.',2),
('«Миротворец»: трагикомедия Джеймса Ганна, которую интереснее смотреть, чем сериалы Marvel',9, '2022-01-12',
'В Амедиатеке (оригинальная платформа — HBO Max) 14 января стартует сериал про нелепого мускулистого пацифиста из «Отряда самоубийц». Марат Шабаев рассказывает
, как режиссер Джеймс Ганн в очередной раз сочувствует костюмированным неудачникам под бодрые рок-хиты 1980-х.',2),
('Питер Богданович: человек, который очень любил кино', 5, '2022-01-10', 
'На 83-м году жизни скончался Питер Богданович, классик американского кино. 
Друг Орсона Уэллса и Джона Форда, фанат черно-белых фильмов, мастер эксцентричных
 комедий и проникновенных драм, тонко чувствующий время и место, Богданович стал 
лицом своего поколения и прожил жизнь, которая сама могла бы лечь в основу отличного байопика.',2),
('Вечная молодость: каким получился второй сезон «Эйфории»', 9, '2022-01-10','
После длинного перерыва сериал о школьнице, которая пытается побороть наркотическую зависимость, 
вновь возвращается на экраны. Рассказываем о том, что происходит с его героями в новом сезоне, и
 выясняем, не растеряла ли «Эйфория» своей художественной радикальности и откровенности.', 2),
 ('Фильм недели. «Майор Гром: Чумной Доктор»', 5, '2022-01-09', 
 'Альтернативный Санкт-Петербург, наши дни. Майор Игорь Гром служит в городской полиции,
 в одиночку ловит преступников, уставу не подчиняется, форму не носит, спорит с начальником
 и очень любит шаверму — словом, типичный герой питерского кинотекста. Правда, пойманных 
нарушителей закона суд иногда отпускает — так от возмездия уходит сын миллиардера, сбивший девочку
 из детдома. Пока Гром от безысходности поколачивает грушу в холостяцкой берлоге, зло в Питере начинает 
выжигать (буквально из огнемета) Чумной Доктор. Он уничтожает богатого убийцу, коррупционеров и прочих 
зарвавшихся хозяев жизни. Параллельно зачисткам Доктор публикует пламенные социальные манифесты в популярной
 соцсети «Вместе», которую создал стартапер Сергей Разумовский. Игорь Гром берется за расследование, в котором
 ему помогают восторженный стажер Дима Дубин и пробивная журналистка Юля Пчелкина.',2),
 ('Как создавался мир «Ведьмака»', 9, '2022-01-06', 
 'Во втором сезоне сериала Netflix появляются новые локации, новые персонажи и новые твари. 
Геральт (Генри Кавилл) возвращается в Каэр Морхен — крепость, где он вырос и обучился всем ведьмацким премудростям.
 Город Цинтра на какое-то время превращается в оплот эльфов. Цири (Фрейя Аллан) пробудила очень древних монстров, и 
со многими ей придется столкнуться лично. Поэтому перед производственными цехами (костюмы, декорации, грим) стояла 
непростая задача — развить мир первого сезона так, чтобы он стал богаче и при этом сохранил узнаваемость. Посмотрим,
 как они с этим справились.', 2), 
 ('13 лучших фильмов ужасов 2021 года. Выбор Зельвенского', 5, '2022-01-05',
 'От Шьямалана до Джеймса Вана, от метахоррора до боди-хоррора, от Кореи до Калабрии — чертова дюжина самого страшно увлекательного кино, вышедшего в прокат в ушедшем году.', 2),
 ('Реальная любовь»: как Тарантино превратился в рождественский капустник', 11, '2022-01-04', 
 'Побивший в прокате третью «Матрицу», вдохновленный «Криминальным чтивом», сделавший несомненными 
звездами всех своих актеров многофигурный фильм Ричарда Кёртиса остается классикой, даже несмотря на 
изменения морально-этического климата и справедливую критику. О том, как из отходов сценарного производства 
была создана одна из лучших рождественских комедий, рассказывает Павел Пугачев.',2),
('Фильм недели. «Отряд самоубийц: Миссия навылет». Как Джеймс Ганн снял самый душевный блокбастер лета', 5, '2022-01-04',
'На Кинопоиске в Плюсе вышел хулиганский кинокомикс Джеймса Ганна о суперзлодеях, спасающих мир. Разбираем, чем хороша новая версия
 приключений Отряда самоубийц и почему фильм нечто большее, чем просто набор крутых экшен-сцен и черного юмора.', 2),
 ('Что смотреть в 2022 году: 50 самых ожидаемых сериалов', 9,'2022-01-03',
 'Спин-оффы «Игры престолов» и «Ведьмака», расширение вселенной «Звездных войн», экранизация культовой игры и финальные сезоны любимых хитов — рассказываем, какие сериалы мы ждем в 2022 году.',2),
 ('Долгожданная «Этерна», «Дюна» и второй сезон «Триггера»: 17 премьер Кинопоиска в январе', 10, '2022-01-02',
 'Романтическая комедия про симбиотов, культовое аниме про титанов и финский кандидат на «Оскар» — рассказываем о 
самых интересных новинках месяца в онлайн-кинотеатре, которые можно посмотреть в Плюсе.',2);
 
 
 

DROP TABLE IF EXISTS news;
CREATE TABLE news (
	id_news BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	news_title TEXT,
	news_type BIGINT UNSIGNED,
	body TEXT,
	publication_time DATE,
	media_type INT UNSIGNED,
	FOREIGN KEY (news_type) REFERENCES types_of_materials (id),
	FOREIGN KEY(media_type) REFERENCES  media_types (id)
);

SELECT body RLIKE 'Леонардо Дикаприо' FROM news;


INSERT INTO news (news_title, news_type, publication_time, body, media_type) values
('«Не смотрите наверх»: веселая гражданская лирика о реакции Америки на приближение смертоносной кометы', 5, '2021-12-24','Аспирантка-астроном (Дженнифер Лоуренс) и ее научный руководитель (Леонардо ДиКаприо)
 обнаруживают комету, которая летит в сторону Земли и, по расчетам, через шесть месяцев и две недели уничтожит все живое. Ученые сообщают о своей находке американскому президенту (Мэрил Стрип), но та поглощена 
скандалом с кандидатом в Верховный суд (обнаружилось, что в прошлом он подрабатывал натурщиком) и не спешит принимать меры. Астрономы решают обратиться к прессе...',2),
('Леонардо ДиКаприо сыграет главную роль в ремейке «Еще по одной»',5,'2021-04-26',
'Компания Леонардо ДиКаприо Appian Way приобрела на аукционе права на ремейк датской драмы Томаса Винтерберга «Еще по одной».
 Новость стала известна в день, когда лента получила «Оскар» как лучший международный фильм. Предполагается, что сценарий новой версии напишут специально под ДиКаприо.
 На данный момент у проекта нет сценариста и режиссера....',2),
 ('Россияне назвали Леонардо ДиКаприо и Александра Петрова главными актерами десятилетия', 5, '2020-11-07',
 'По мнению российских зрителей, Леонардо ДиКаприо как актер оказал наибольшее влияние на зарубежный кинематограф в последнее десятилетие. Это следует из результатов опроса портала SuperJob.
Звезду «Выжившего» и «Однажды... в Голливуде» поддержали 12% опрошенных. Вторую строчку занял Джонни Депп — он отстает от ДиКаприо на 2%. Далее следуют Роберт Дауни-мл., Брэд Питт и Джеки Чан —
 за них проголосовали 3—5% респондентов.',2),
('Квентин Тарантино выпустит две книги — новеллизацию «Однажды… в Голливуде» и про кинематограф 1970-х', 5, '2021-11-17',
'Квентин Тарантино заключил контракт с издательской компанией HarperCollins. Соглашение подразумевает выпуск двух книг режиссера.
Первая книга — новеллизация фильма «Однажды… в Голливуде». В ней режиссер подробнее расскажет о главных героях, актере Рике Далто
не и его дублере Клиффе Буте, которых сыграли Леонардо ДиКаприо и Брэд Питт. Тарантино опишет их предысторию, а также эпизоды, не
 вошедшие в фильм. Часть из них будет посвящена попытке Далтона построить карьеру в Италии. Как сообщает Deadline, одним из героев книги станет актер Берт Рейнолдс.',2),
('Леонардо ДиКаприо, Мэрил Стрип и Джона Хилл сыграют в комедии Адама МакКея', 5,'2020-10-14', 
'Леонардо ДиКаприо, Джона Хилл, Мэрил Стрип и Химеш Патель («Довод») пополнили актерский сост
ав комедии «Не смотри вверх». Ее снимет Адам МакКей, режиссер фильмов «Игра на понижение», «Власть» и «Копы в глубоком запасе». Он же написал сценарий.',2),
('Бэйл в роли Халка и Дауни-мл. в «Джокере»: Vulture представил альтернативную историю Marvel и DС', 5,'2021-01-17,', 'Железный человек все же умирает в «Мстителях», но в первых
После успеха с «Халком» Marvel предлагает Нолану снять «Мстителей», однако у режиссера назревает конфликт со студией, когда он пытается вписать 
в мрачный фильм жизнерадостных героев вроде Тора и Капитана Америка. Вскоре Нолан покидает проект, и на его место приглашают Джосса Уидона.
 Тот решает, что один из героев должен умереть в финале, и, поскольку Халк — главная звезда франшизы, выбор падает на Железного человека. 
Гибель Тони Старка вызывает бурную реакцию зрителей, некоторые требуют, чтобы студия выпустила версию Нолана (знакомо, не правда ли?).
ДиКаприо получает «Оскар»… за «Начало»
Оставив «Мстителей», Нолан берется за «Начало». Фильм выходит в 2014 году и становится хитом. Нолана номинируют на «Оскар» за режиссуру, 
а Леонардо ДиКаприо награждают долгожданной статуэткой за главную мужскую роль (зато спустя год Лео проиграет Мэтту Дэймону, который снимется в 
«Марсианине», а Эдди Редмэйн ничего не получит — после победы Хаффман в Голливуде бойкотируют цисгендерных актеров, играющих трансперсон).',2),
('Исследование: Киану Ривз и Джейк Джилленхол снимаются в секс-сценах чаще других актеров', 5,'2020-10-13','Американская писательница Кэрри 
Уиттмер опубликовала рейтинг актеров, которые снимались в откровенных эпизодах. Главный критерий топа — суммарная продолжительность секс-сцен,
 в которых участвуют их герои. Уиттмер потратила на исследование четыре месяца. За это время она изучила фильмографии десятков звезд, в том числе 
самых высокооплачиваемых, обладателей «Оскара» и тех, кого часто обсуждали в последние годы.
Уиттмер учитывала сцены, которые подразумевают (пусть и не показывают) оральный секс или пенетрацию, 
секс за кадром (если есть аудио- или визуальные намеки на половой акт) и сцены с мастурбацией, если 
в них участвуют более одного человека. Сериалы Уиттмер не рассматривала.,2
Топ писательницы выглядит так:
1. Киану Ривз — 568,92 секунды (12 фильмов);
2. Роберт Паттинсон — 410,95 секунды (8 фильмов);
3. Джейк Джилленхол — 404,51 секунды (10 фильмов);
4. Брэд Питт — 392,07 секунды (8 фильмов);
5. Роберт Дауни-мл. — 337,14 секунды (5 фильмов);
6. Марк Уолберг — 320,26 секунды (6 фильмов);
7. Леонардо ДиКаприо — 260,62 секунды (5 фильмов);
8. Бен Аффлек — 184 секунды (6 фильмов);
9. Том Круз — 176 секунд (7 фильмов);
10. Тимоти Шаламе — 162,33 секунды (5 фильмов);
11. Брэдли Купер — 151,7 секунды (6 фильмов);
12. Крис Эванс — 135 секунд (3 фильма);',2),
('Думаете, что разбираетесь в кино? Проверьте свои знания о любимых фильмах, сериалах и актерах в нашем КиноКвизе!',
5,'2020-11-11','Какой фильм был номинирован на рекордное количество «Оскаров»? Кто появлялся в камео в сериале «Друзья»? 
И правда ли, что Киану Ривз производит мотоциклы? На YouTube-канале КиноПоиска теперь есть онлайн-киноквиз, в который можно
 играть и с друзьями (офлайн или удаленно), и одному (если вы интроверт или просто скучаете). Смотрите, отвечайте на вопросы 
и делитесь результатами в комментариях.',3),
('Флешмоб дня: Киркоров вместо Джонни Деппа и Басков в роли Халка',2, '2020-08-05',
'А вот как выглядел бы Рик Далтон, если бы в «Однажды в… Голливуде» его сыграл не Леонардо ДиКаприо, а Квентин Тарантино.
',3),
('А вот как выглядел бы Рик Далтон, если бы в «Однажды в… Голливуде» его сыграл не Леонардо ДиКаприо, а Квентин Тарантино.
', 5,'2020-07-16', 
'16 июля 2010 года в мировой прокат вышел фильм «Начало» Кристофера Нолана, в котором Леонардо ДиКаприо, Эллен Пейдж и Джозеф 
Гордон-Левитт сыграли похитителей информации, проникающих в чужие сны. Картина получила четыре «Оскара» и была высоко оценена
 и критиками, и зрителями. Вспоминаем, как снимали «Начало».',2),
('Леонардо ДиКаприо и Роберт Де Ниро предложили фанатам роль в новом фильме Мартина Скорсезе', 5, '2019-12-11',
 'мериканский бизнесмен Майкл Рубин запустил благотворительную кампанию для звезд All In Challenge,
 цель которой — собрать деньги на питание пожилым, детям и нуждающимся во время пандемии коронавируса. 
К ней присоединились Леонардо ДиКаприо и Роберт Де Ниро, которые в обмен на пожертвование предлагают фанатам 
возможность стать частью нового фильма Мартина Скорсезе «Убийцы цветочной луны». Победитель получит роль в массовке, побывает на площадке и посетит',2),
('Сэмюэл Л. Джексон больше не король мата в Голливуде. Его сместил Джона Хилл', 5, '2020-04-06',
'Сайт BuzzBingo провел исследование и выяснил, какие актеры чаще всего ругаются в кадре. Просмотрев 3500 киносценариев они выяснили,
 что Сэмюэл Л. Джексон, считавшийся одним из самых матерящихся актеров кино, на самом деле занимает лишь третье место с 301 ругательством.
 На втором месте оказался Леонардо ДиКаприо с 361 ругательством. Чаще других в фильмах неприлично выражался Джона Хилл, на счету которого 376 ругательств.',2),
 ('Мартин Скорсезе приступит к съемкам нового фильма с ДиКаприо ближайшей весной',5, '2019-12-03',
 'Съемки следующего фильма Мартина Скорсезе, триллера «Убийцы лунного цветка», начнутся в марте 2020 года. Об этом в разговоре с Collider сообщил оператор картины Родриго Прието.
По словам Прието, он уже сделал несколько пробных кадров в Оклахоме, где пройдут основные съемки, и в скором времени решит, какой тональности будет придерживаться фильм.
«Прямо сейчас я исследую различные методы съемок, — рассказал Прието. — Нам со Скорсезе еще предстоит встретиться, я покажу ему кадры, поделюсь идеями. Возможно, он предложит свои,
 хотя мы до сих пор не определились с тональностью фильма. Так что все впереди».
Главные роли в фильме сыграют Леонардо ДиКаприо и Роберт Де Ниро. В отличие от 
«Ирландца», выпущенного на Netflix, у «Убийц лунного цветка» будет кинотеатральный прокат — картину выпустит Paramount Pictures.',2),
('Президент Бразилии обвинил Леонардо ДиКаприо в финансировании лесных пожаров',5,'2019-12-02', 
'Во время прямой трансляции в Facebook президент Бразилии Жаир Болсонару заявил, что Леонардо ДиКаприо несет частичную ответственность за лесные пожары в Амазонии.
 Болсонару обвинил актера в финансировании некоммерческих организаций, которые и подожгли леса.',2),
 ('Оскар-2020»: Девять фильмов, которые точно понравятся академикам',5, NULL, 
 'О чем: 1969 год, начало Нового Голливуда и конец Голливуда старого. Бывшая звезда Рик Далтон 
(Леонардо ДиКаприо) пытается остаться на плаву, хотя больших ролей ему давно уже не предлагают. 
Тем обиднее, что его соседи — модный режиссер Роман Полански и его жена, актриса Шэрон Тейт (Марго Робби). 
А где-то неподалеку уже начинает строить коварные планы Чарльз Мэнсон c толпой своих послушных последователей.',2),
 ('Леонардо ДиКаприо согласился на роль в «Титанике» благодаря Полу Радду',5,'2019-10-17',
 'Во время записи передачи Грэма Нортона Пол Радд припомнил, что в свое время подтолкнул Леонардо ДиКаприо
к решению сняться в «Титанике». В конце 1990-х они вместе работали над картиной База Лурмана «Ромео + Джульетта»,
 когда ДиКаприо поступило предложение исполнить главную роль в фильме Джеймса Кэмерона.',2),
('Великолепная отсылка: из чего собран «Однажды в... Голливуде»', 3, '2019-08-13', '...Филлипс из The Mamas And The Papas.
 В действительности, по свидетельству Майкла Кейна, однажды группа давала вечеринку, где были и Тейт, и Сибринг, и Мэнсон.
Рик Далтон (Леонардо ДиКаприо) и Клифф Бут (Брэд Питт)',2),
('В прокате — драма Озона об эвтаназии. Советуем 8 фильмов об умирании и рассказываем, зачем их вообще смотреть', 2, '2022-01-21' ,'
В кино можно посмотреть фильм Франсуа Озона «Все прошло хорошо». В центре истории — 85-летний Андре (Андре Дюссолье).
 После инсульта он оказывается парализован и тогда просит дочь (Софи Марсо) помочь ему с эвтаназией. К теме смерти обращался 
не только Озон. Мы расспросили психолога, зачем смотреть фильмы о смерти и какие проблемы они помогут выявить. Вдобавок выбрали
 восемь фильмов, где у героев умирает кто-то из близких и они по-разному пытаются это прожить.
',2),
('«Макбет харизматичен, но он, по сути, гангстер». Фрэнсис МакДорманд и Джоэл Коэн — о своем последнем фильме', 7, '2022-01-21',
'14 января на Apple TV+ вышла «Трагедия Макбета» — исторический триллер Джоэла Коэна, снятый по пьесе Шекспира. 
Это первый сольный режиссерский проект Джоэла без участия брата Итана. Оскароносная Фрэнсис МакДорманд, супруга
 режиссера, сыграла роль леди Макбет и выступила сопродюсером проекта. Юлия Лоло встретилась с актрисой и режиссером
 и обсудила с ними Дензела Вашингтона в роли Макбета, съемки в локдаун и сложности работы с черно-белой картиной.',2),
('Новый «Человек-паук» поменял правила игры в своих вселенных. Как это произошло и что будет дальше?', 8, '2022-01-21',
'Фильм стал дважды эпохальным. Во-первых, подвел итог двадцатилетней истории полнометражных экранизаций комиксов о 
Человеке-пауке и примирил фанатов разных интерпретаций персонажа.',2),
('Что смотреть дома: «Этерна: Часть первая», «Карамора», новая «Матрица»', 1,'2022-01-21',
'Начало фэнтези-саги по романам Веры Камши, исторический триллер про анархиста, который воюет
 с вампирами, и возвращение героев культового философского боевика — рассказываем о главных 
новинках российских и зарубежных стримингов на этой неделе.',2);
 
 
 

CREATE TABLE zodiac(
	id BIGINt UNSIGNED NOT NULL PRIMARY KEY
	date_ DATE
	sign VARCHAR(230)
);







-- Здесь раздел из "неработающих функций", может быть потом доберусь до того, почему они не запускаются))


DROP FUNCTION IF EXISTS zodiac;
SELECT month((SELECT birthday FROM profiles WHERE user_id= 268)), day((SELECT birthday FROM profiles WHERE user_id= 268));
SELECT EXTRACT(DAY_MONTH FROM birthday) AS one FROM profiles WHERE user_id = 268;
SELECT convert('2017-10-11', varchar(200));
SELECT date_format(birthday, '%d.%m') FROM profiles WHERE user_id=268; 



SELECT STR_TO_DATE(@24, '%Y%d.%m');
SELECT STR_TO_DATE(@24, '%d.%m') > (SELECT STR_TO_DATE(@23, '%d.%m'));
SELECT str_to_date((date_format('2017-02-27', '%d.%m')),'%d.%m') BETWEEN (SELECT STR_TO_DATE(@23, '%d.%m')) AND (SELECT STR_TO_DATE(@24, '%d.%m'));
SELECT @21;
SELECT REPLACE(@21,'.','');
SELECT CAST((SELECT REPLACE((SELECT date_format(birthday, '%d') FROM profiles WHERE user_id = 268),'.','')) AS SIGNED) AS days;
SELECT CAST((SELECT REPLACE((SELECT date_format(birthday, '%m') FROM profiles WHERE user_id = 268),'.','')) AS SIGNED) AS monthes;
SELECT date_format(birthday, '%d.%m') FROM profiles WHERE user_id= 268;

SELECT date_format('0000-04-19','%m');

 SET @apha := (SELECT concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = 268),'%Y')),'-',(SELECT date_format('0000-04-19','%m')), '-',(SELECT date_format ('0000-04-19','%d'))));
SELECT str_to_date(@alpha, '%Y.%m%.%d');

SELECT str_to_date((SELECT concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = 268),'%Y')),'-',(SELECT date_format('0000-04-19','%m')), '-',(SELECT date_format ('0000-04-19','%d')))), '%Y.%m.%d');



(SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = 268),'%Y'))
,'-',(SELECT date_format('2017-04-19','%m')), '-',(SELECT date_format ('2017-04-19','%d'))), '%Y.%m.%d')),'%Y.%m.%d')));



SELECT DAYOFYEAR((SELECT birthday FROM profiles WHERE user_id = 268)) ;

SELECT DAYOFYEAR(str_to_date(concat((date_format((SELECT birthday FROM profiles WHERE user_id = 268),'%Y')),'-',(SELECT date_format('2017-04-19','%m')), '-',(SELECT date_format ('2017-04-19','%d')))), '%Y,%m,%d');
SELECT date_format((SELECT birthday FROM profiles WHERE user_id = 268),'%Y');
DELIMITER //


SELECT  DAYOFYEAR((SELECT birthday FROM profiles WHERE user_id = 359)) BETWEEN ((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = 359),'%Y'))
,'-',(SELECT date_format('0000-01-01','%m')), '-',(SELECT date_format ('0000-01-01','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
AND 
((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = 359),'%Y'))
,'-',(SELECT date_format('0000-01-20','%m')), '-',(SELECT date_format ('0000-01-20','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))));





CREATE FUNCTION zodiac (person BIGINT UNSIGNED)
RETURNS TEXT READS SQL DATA NOT DETERMINISTIC
BEGIN		
		DECLARE birthday BIGINT;
	SET birthday = (SELECT DAYOFYEAR((SELECT birthday FROM profiles WHERE user_id = 268)));
	CASE 
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-03-21','%m')), '-',(SELECT date_format ('0000-03-21','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-04-20','%m')), '-',(SELECT date_format ('0000-04-20','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Овен';	
	WHEN birthday  BETWEEN 
	(SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-04-21','%m')), '-',(SELECT date_format ('0000-04-21','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-05-21','%m')), '-',(SELECT date_format ('0000-05-21','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	THEN
	RETURN 'Телец';
	WHEN birthday  BETWEEN
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-05-22','%m')), '-',(SELECT date_format ('0000-05-22','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-06-21','%m')), '-',(SELECT date_format ('0000-06-21','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	THEN
	RETURN 'Близнецы';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-06-22','%m')), '-',(SELECT date_format ('0000-06-22','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-07-22','%m')), '-',(SELECT date_format ('0000-07-22','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Рак';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-07-23','%m')), '-',(SELECT date_format ('0000-07-23','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-08-23','%m')), '-',(SELECT date_format ('0000-08-23','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	 THEN
	RETURN 'Лев';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-08-24','%m')), '-',(SELECT date_format ('0000-08-24','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-09-22','%m')), '-',(SELECT date_format ('0000-09-22','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	 THEN
	RETURN 'Дева';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-09-23','%m')), '-',(SELECT date_format ('0000-09-23','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-10-23','%m')), '-',(SELECT date_format ('0000-10-23','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Весы';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-10-24','%m')), '-',(SELECT date_format ('0000-10-24','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-11-22','%m')), '-',(SELECT date_format ('0000-11-22','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Скорпион';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-11-23','%m')), '-',(SELECT date_format ('0000-11-23','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-12-21','%m')), '-',(SELECT date_format ('0000-12-21','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Стрелец ';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-12-21','%m')), '-',(SELECT date_format ('0000-12-21','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-12-31','%m')), '-',(SELECT date_format ('0000-12-31','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Козерог';
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-01-01','%m')), '-',(SELECT date_format ('0000-01-01','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-01-20','%m')), '-',(SELECT date_format ('0000-01-20','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Козерог'; 
	WHEN birthday  BETWEEN 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-01-21','%m')), '-',(SELECT date_format ('0000-01-21','%d'))), '%Y.%m.%d')),'%Y.%m.%d')))) 
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-02-18','%m')), '-',(SELECT date_format ('0000-02-18','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Водолей';
	WHEN birthday  BETWEEN
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-02-19','%m')), '-',(SELECT date_format ('0000-02-19','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	AND 
	((SELECT DAYOFYEAR(str_to_date((SELECT date_format(concat((SELECT date_format((SELECT birthday FROM profiles WHERE user_id = person),'%Y'))
	,'-',(SELECT date_format('0000-03-20','%m')), '-',(SELECT date_format ('0000-03-20','%d'))), '%Y.%m.%d')),'%Y.%m.%d'))))
	THEN
	RETURN 'Рыбы';
	ELSE
		BEGIN
		END;
	END CASE;
END//
DELIMITER ;

DROP FUNCTION IF EXISTS zodiac;

SELECT zodiac(268);
 
DELIMITER //
CREATE FUNCTION zodiac (person BIGINT UNSIGNED)
RETURNS TEXT DETERMINISTIC
BEGIN
	DECLARE birthday int;



DELIMITER //
CREATE FUNCTION zodiac (person BIGINT UNSIGNED)
RETURNS TEXT DETERMINISTIC
BEGIN
	DECLARE sign_day INT;
	SET sign_day = DAY((SELECT birthday FROM profiles WHERE user_id = person));	
	CASE 
	WHEN (sign_day >= 21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'March'))
	AND (sign_day <= 20 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'April')) THEN
	RETURN 'Овен';
	WHEN (sign_day >=21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'April'))
	AND  (sign_day <= 21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'May')) THEN
	RETURN 'Телец';
	WHEN (sign_day >= 22 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'May'))
	AND (sign_day  <= 21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'June')) THEN
	RETURN 'Близнецы';
	WHEN (sign_day >= 21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'June'))
	AND (sign_day <= 22 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'July')) THEN
	RETURN 'Рак';
	WHEN(sign_day >= 23 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'July'))
	AND (sign_day <= 21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'August')) THEN
	RETURN 'Лев';
	WHEN (sign_day >=23 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'August'))
	AND (sign_day <=21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'September')) THEN
	RETURN 'Дева';
	WHEN  (sign_day >=24 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'September'))
	AND (sign_day <=23  AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'October')) THEN
	RETURN 'Весы';
	WHEN  (sign_day >=24 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'October'))
	AND (sign_day <=23 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'November')) THEN
	RETURN 'Скорпион';	
	WHEN  (sign_day >=24 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'November'))
	AND (sign_day <=22 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'December')) THEN
	RETURN 'Стрелец ';	
	WHEN  (sign_day >=23 AND  monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'December'))
	AND (sign_day <=20 AND  monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'January')) THEN
	RETURN 'Козерог';
	WHEN (sign_day >=21 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'January'))
	AND (sign_day <=19 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'February')) THEN
	RETURN 'Водолей';
	WHEN  (sign_day >=20 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'February'))
	AND (sign_day <=20 AND monthname((SELECT birthday FROM profiles WHERE user_id = person) = 'March')) THEN
	RETURN 'Рыбы';
	END CASE;
END;
DELIMITER ;


SELECT  birthday FROM profiles WHERE monthname = 'March'; 
SELECT monthname()


ALTER TABLE profiles MODIFY COLUMN birthday DATE NOT NULL;
SELECT MONTH((SELECT birthday FROM profiles WHERE user_id =268));
 
 
 DELIMITER //
CREATE FUNCTION zodiac (person BIGINT UNSIGNED)
RETURNS TEXT READS SQL DATA NOT DETERMINISTIC
BEGIN    
    DECLARE birthday DATE;
  SET birthday = (SELECT STR_TO_DATE((SELECT date_format(birthday, '%d.%m') FROM profiles WHERE user_id = person), '%d.%m'));
  CASE 
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@1, '%d.%m')) AND (SELECT STR_TO_DATE(@2, '%d.%m'))
  THEN
  RETURN 'Овен';  
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@3, '%d.%m')) AND (SELECT STR_TO_DATE(@4, '%d.%m'))
  THEN
  RETURN 'Телец';
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@5, '%d.%m')) AND (SELECT STR_TO_DATE(@6, '%d.%m'))
  THEN
  RETURN 'Близнецы';
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@7, '%d.%m')) AND (SELECT STR_TO_DATE(@8, '%d.%m'))
  THEN
  RETURN 'Рак';
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@9, '%d.%m')) AND (SELECT STR_TO_DATE(@10, '%d.%m'))
   THEN
  RETURN 'Лев';
  WHEN birthday  BETWEEN  (SELECT STR_TO_DATE(@11, '%d.%m')) AND (SELECT STR_TO_DATE(@12, '%d.%m'))
   THEN
  RETURN 'Дева';
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@13, '%d.%m')) AND (SELECT STR_TO_DATE(@14, '%d.%m'))
  THEN
  RETURN 'Весы';
  WHEN birthday  BETWEEN  (SELECT STR_TO_DATE(@15, '%d.%m')) AND (SELECT STR_TO_DATE(@16, '%d.%m'))
  THEN
  RETURN 'Скорпион';
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@17, '%d.%m')) AND (SELECT STR_TO_DATE(@18, '%d.%m'))
  THEN
  RETURN 'Стрелец ';
  WHEN birthday  BETWEEN  (SELECT STR_TO_DATE(@19, '%d.%m')) AND (SELECT STR_TO_DATE(@20, '%d.%m'))
  THEN
  RETURN 'Козерог';
  WHEN birthday  BETWEEN  (SELECT STR_TO_DATE(@21, '%d.%m')) AND (SELECT STR_TO_DATE(@22, '%d.%m'))
  THEN
  RETURN 'Водолей';
  WHEN birthday  BETWEEN (SELECT STR_TO_DATE(@23, '%d.%m')) AND (SELECT STR_TO_DATE(@24, '%d.%m'))
  THEN
  RETURN 'Рыбы';
  ELSE
    BEGIN
    END;
  END CASE;
END//
DELIMITER ;



