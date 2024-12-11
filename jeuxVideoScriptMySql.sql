create database JeuxVideo
use JeuxVideo

create table MEMBRE(
    id INT PRIMARY KEY,
    pseudo VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    date_inscription DATE NOT NULL
);

CREATE TABLE JEU (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(100) NOT NULL,
    studio_developpement VARCHAR(100),
    annee_sortie INT,
    genre VARCHAR(50),
    multijoueur BOOLEAN
);
CREATE TABLE TOURNOI (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_tournoi VARCHAR(100) NOT NULL,
    date_tournoi DATE NOT NULL,
    recompenses TEXT
);

CREATE TABLE ABONNEMENT (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_abonnement VARCHAR(50) NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    membre_id INT,
    FOREIGN KEY (membre_id) REFERENCES MEMBRE(id)
);

CREATE TABLE EMPRUNTER (
    membre_id INT,
    jeu_id INT,
    date_emprunt DATE NOT NULL,
    date_retour_prevue DATE NOT NULL,
    date_retour_reelle DATE,
    PRIMARY KEY (membre_id, jeu_id, date_emprunt),
    FOREIGN KEY (membre_id) REFERENCES MEMBRE(id),
    FOREIGN KEY (jeu_id) REFERENCES JEU(id)
);

CREATE TABLE PARTICIPER (
    membre_id INT,
    tournoi_id INT,
    score INT,
    rang_final INT,
    PRIMARY KEY (membre_id, tournoi_id),
    FOREIGN KEY (membre_id) REFERENCES MEMBRE(id),
    FOREIGN KEY (tournoi_id) REFERENCES TOURNOI(id)
);

INSERT INTO MEMBRE (id, pseudo, email, date_inscription) VALUES 
(1, 'Player1', 'player1@email.com', '2024-01-01'),
(2, 'GameMaster', 'gm@email.com', '2024-01-15'),
(3, 'ProGamer', 'pro@email.com', '2024-02-01');

INSERT INTO JEU (titre, studio_developpement, annee_sortie, genre, multijoueur) VALUES 
('The Last Adventure', 'GameStudio', 2023, 'Adventure', true),
('Space Wars', 'CosmicGames', 2024, 'Action', true),
('Mystery Island', 'IslandDev', 2022, 'RPG', false);

INSERT INTO TOURNOI (nom_tournoi, date_tournoi, recompenses) VALUES 
('Summer Championship', '2024-06-15', 'Trophy + 1000€'),
('Winter League', '2024-12-01', 'Medal + 500€'),
('Spring Tournament', '2024-03-20', 'Cup + 750€');

INSERT INTO ABONNEMENT (type_abonnement, date_debut, date_fin, membre_id) VALUES 
('Premium', '2024-01-01', '2024-12-31', 1),
('Basic', '2024-02-01', '2024-07-31', 2),
('Gold', '2024-03-01', '2025-02-28', 3);

INSERT INTO EMPRUNTER (membre_id, jeu_id, date_emprunt, date_retour_prevue, date_retour_reelle) VALUES 
(1, 1, '2024-01-15', '2024-01-22', '2024-01-21'),
(2, 2, '2024-02-01', '2024-02-08', NULL),
(3, 3, '2024-02-15', '2024-02-22', '2024-02-20');

INSERT INTO PARTICIPER (membre_id, tournoi_id, score, rang_final) VALUES 
(1, 1, 1000, 1),
(2, 1, 850, 2),
(3, 1, 750, 3);

#Lister les informations de tous les membres (pseudo, e-mail, date d'inscription).
SELECT * FROM MEMBRE;
SELECT titre, studio_developpement, genre FROM JEU;
SELECT *
FROM TOURNOI
WHERE nom_tournoi = 'Summer Championship';

SELECT m.pseudo,j.titre,e.date_emprunt,e.date_retour_prevue
FROM EMPRUNTER e
JOIN MEMBRE m ON e.membre_id = m.id
JOIN JEU j ON e.jeu_id = j.id
WHERE e.date_retour_reelle IS NULL;
/* Lister les membres ayant participé à un tournoi, avec leur pseudo, le nom du tournoi, et leur rang final.*/

SELECT 
    m.pseudo,
    t.nom_tournoi,
    p.rang_final
FROM PARTICIPER p
JOIN MEMBRE m ON p.membre_id = m.id
JOIN TOURNOI t ON p.tournoi_id = t.id
ORDER BY t.nom_tournoi, p.rang_final;

/*Trouver les membres qui ont souscrit à un abonnement annuel.*/
SELECT 
    m.pseudo,
    a.type_abonnement,
    a.date_debut,
    a.date_fin,
    DATEDIFF(a.date_fin, a.date_debut) as duree_jours
FROM ABONNEMENT a
JOIN MEMBRE m ON a.membre_id = m.id
WHERE DATEDIFF(a.date_fin, a.date_debut) >= 365;

/* Trouver les jeux empruntés par un membre spécifique (via son pseudo).  */
SELECT 
    j.titre,
    e.date_emprunt,
    e.date_retour_prevue,
    e.date_retour_reelle
FROM EMPRUNTER e
JOIN MEMBRE m ON e.membre_id = m.id
JOIN JEU j ON e.jeu_id = j.id
WHERE m.pseudo = 'Player1';

/* Lister tous les emprunts, en incluant le pseudo du membre et les informations sur le jeu (titre et studio de développement).*/
SELECT 
    m.pseudo,
    j.titre,
    j.studio_developpement,
    e.date_emprunt,
    e.date_retour_prevue,
    e.date_retour_reelle
FROM EMPRUNTER e
JOIN MEMBRE m ON e.membre_id = m.id
JOIN JEU j ON e.jeu_id = j.id
ORDER BY e.date_emprunt;

/*Afficher la liste des membres et le type d'abonnement auquel ils sont associés.*/

SELECT 
    m.pseudo,
    m.email,
    a.type_abonnement,
    a.date_debut,
    a.date_fin
FROM MEMBRE m
JOIN ABONNEMENT a ON m.id = a.membre_id
ORDER BY m.pseudo;

/*Calculer le nombre total de jeux disponibles par genre.*/
SELECT 
    genre,
    COUNT(*) as nombre_jeux
FROM JEU
GROUP BY genre
ORDER BY nombre_jeux DESC;

/*Trouver le tournoi avec le plus grand nombre de participants.*/
SELECT 
    t.nom_tournoi,
    t.date_tournoi,
    COUNT(p.membre_id) as nombre_participants
FROM TOURNOI t
LEFT JOIN PARTICIPER p ON t.id = p.tournoi_id
GROUP BY t.id, t.nom_tournoi, t.date_tournoi
ORDER BY nombre_participants DESC;

/*Afficher le nombre d'emprunts réalisés par chaque membre.*/
SELECT 
    m.pseudo,
    COUNT(e.jeu_id) as nombre_emprunts,
    COUNT(CASE WHEN e.date_retour_reelle IS NULL THEN 1 END) as emprunts_en_cours
FROM MEMBRE m
LEFT JOIN EMPRUNTER e ON m.id = e.membre_id
GROUP BY m.id, m.pseudo
ORDER BY nombre_emprunts DESC;