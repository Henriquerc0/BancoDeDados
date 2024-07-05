create database if not exists atividade_n3;
use atividade_n3;

-- Tabelas
create table if not exists Filme (
    ID_Filme int primary key not null,
    Titulo varchar (255) not null,
    Genero varchar (255) not null,
	Classificacao varchar (255) not null,
	Ano int

    -- se colocar mais atributos tem que lembra de mudar no DER
);

create table if not exists Genero (
    ID_Genero int primary key not null,
    Nome varchar (100) not null
    -- se colocar mais atributos tem que lembra de mudar no DER
);

create table if not exists Usuario (
    ID_Usuario int primary key not null auto_increment,
    Nome varchar (100) not null,
    Email varchar (255) not null,
    Senha varchar (255) not null
    -- se colocar mais atributos tem que lembra de mudar no DER
);

create table if not exists Filme_Genero (
    ID_Filme int,
    ID_Genero int,
    primary key (ID_Filme, ID_Genero),
    foreign key (ID_Filme) references Filme(ID_Filme),
    foreign key  (ID_Genero) references Genero(ID_Genero)
);

create table if not exists Assistiu (
    id_Usuario int,
    id_Filme int,
    Avaliacao decimal(2,1),
    Tempo_Assistido time,
    Concluido BOOLEAN,
    primary key (ID_Usuario, ID_Filme),
    foreign key  (ID_Usuario) references Usuario(ID_Usuario),
    foreign key  (ID_Filme) references Filme(ID_Filme)
);

insert into Usuario (Nome, Email, Senha)
values ('Jefferson', 'jefferson@p.ucb.com', '123filmes');

-- Views
create view Filmes_Com_Generos as
select f.Titulo, GROUP_CONCAT(g.Nome separator ', ') as Generos, avg(a.Avaliacao) as Avaliacao_Geral
from Filme f
join Filme_Genero fg on f.ID_Filme = fg.ID_Filme
join Genero g on fg.ID_Genero = g.ID_Genero
left join Assistiu a on f.ID_Filme = a.ID_Filme
group by f.Titulo
having COUNT(g.ID_Genero) <= 3;

create view Filmes_Assistidos_por_Usuario as
select f.Titulo, a.Avaliacao
from Filme f
join Assistiu a on f.ID_Filme = a.ID_Filme
where a.ID_Usuario = 'Jefferson';

create view Usuario_com_Genero_Favorito as
select u.Nome, g.Nome as Genero_Favorito
from Usuario u
join (
    select ID_Usuario, ID_Genero, COUNT(*) AS Contagem
    from (
        select a.ID_Usuario, fg.ID_Genero
        from Assistiu a
        join Filme_Genero fg on a.ID_Filme = fg.ID_Filme
        group by a.ID_Usuario, fg.ID_Genero
    ) as Tabela_Grupos
    where Contagem = (
        select MAX(Contagem)
        from (
            select ID_Usuario, ID_Genero, COUNT(*) as Contagem
            from (
                select a.ID_Usuario, fg.ID_Genero
                from Assistiu a
                join Filme_Genero fg on a.ID_Filme = fg.ID_Filme
                group by a.ID_Usuario, fg.ID_Genero
            ) as Tabela_Grupos
            group by ID_Usuario
        ) as Tabela_Fix
    )
) as Genero on u.ID_Usuario = Genero.ID_Usuario;

grant select on Filmes_Com_Generos to 'Jefferson'@'localhost' identified by '123filmes';
grant select on Filmes_Assistidos_Por_Usuario to 'Jefferson'@'localhost' identified by '123filmes';
grant select on Usuario_com_genero_favorito to 'Jefferson'@'localhost' identified by '123filmes';

alter user 'Jefferson'@'localhost' identified by '123filmes' password expire interval 180 day;