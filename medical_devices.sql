--
-- PostgreSQL database dump
--

\restrict TBrX9a5p37OHgID2uIUfV81wvFMISOXtyaWscbs6lTv4Am62y9wC4r4SmSEdzfB

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-04-01 17:18:52

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 239 (class 1255 OID 17674)
-- Name: avg_sale_price_in_period(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.avg_sale_price_in_period(start_date date, end_date date) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_price NUMERIC;
BEGIN
    SELECT ROUND(AVG(sale_price), 2) INTO avg_price
    FROM sales
    WHERE sale_date BETWEEN start_date AND end_date;
    RETURN avg_price;
END;
$$;


--
-- TOC entry 238 (class 1255 OID 17673)
-- Name: cheap_devices_share(character varying, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cheap_devices_share(supplier_name character varying, max_price numeric) RETURNS real
    LANGUAGE plpgsql
    AS $$
DECLARE
    cheap_count REAL;
    total_count REAL;
BEGIN
    SELECT COUNT(*) INTO cheap_count
    FROM medical_devices md
    JOIN suppliers sp ON md.supplier_id = sp.supplier_id
    WHERE sp.name = supplier_name AND md.price < max_price;

    SELECT COUNT(*) INTO total_count
    FROM medical_devices md
    JOIN suppliers sp ON md.supplier_id = sp.supplier_id
    WHERE sp.name = supplier_name;

    RETURN CASE WHEN total_count > 0 THEN cheap_count / total_count ELSE 0 END;
END;
$$;


--
-- TOC entry 252 (class 1255 OID 17677)
-- Name: defective_devices_by_manufacturer(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.defective_devices_by_manufacturer(manuf_name character varying) RETURNS TABLE(name character varying, release_date date, is_defective boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, md.release_date, md.is_defective
    FROM medical_devices md
    JOIN manufacturers m ON md.manufacturer_id = m.manufacturer_id
    WHERE m.name = manuf_name AND md.is_defective = TRUE
    ORDER BY md.release_date;
END;
$$;


--
-- TOC entry 231 (class 1255 OID 17665)
-- Name: device_extremes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.device_extremes() RETURNS TABLE(most_expensive numeric, cheapest numeric, avg_price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        MAX(price),
        MIN(price),
        ROUND(AVG(price), 2)
    FROM medical_devices;
END;
$$;


--
-- TOC entry 229 (class 1255 OID 17663)
-- Name: device_info(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.device_info() RETURNS TABLE(name character varying, release_date date, manufacturer character varying, supplier character varying, city character varying, price numeric, sale_date date, client character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        md.name,
        md.release_date,
        m.name,
        s.name,
        c.city_name,
        md.price,
        sl.sale_date,
        cl.client_name
    FROM medical_devices md
    LEFT JOIN manufacturers m ON md.manufacturer_id = m.manufacturer_id
    LEFT JOIN suppliers s ON md.supplier_id = s.supplier_id
    LEFT JOIN cities c ON s.city_id = c.city_id OR m.city_id = c.city_id
    LEFT JOIN sales sl ON md.device_id = sl.device_id
    LEFT JOIN clients cl ON sl.client_id = cl.client_id
    ORDER BY md.name;
END;
$$;


--
-- TOC entry 251 (class 1255 OID 17675)
-- Name: devices_above_manufacturer_avg(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_above_manufacturer_avg(manuf_name character varying) RETURNS TABLE(name character varying, price numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_price NUMERIC;
BEGIN
    SELECT AVG(md2.price) INTO avg_price
    FROM medical_devices md2
    JOIN manufacturers m2 ON md2.manufacturer_id = m2.manufacturer_id
    WHERE m2.name = manuf_name;

    RETURN QUERY
    SELECT md.name, md.price
    FROM medical_devices md
    JOIN manufacturers m ON md.manufacturer_id = m.manufacturer_id
    WHERE m.name = manuf_name AND md.price > avg_price
    ORDER BY md.price;
END;
$$;


--
-- TOC entry 255 (class 1255 OID 17679)
-- Name: devices_by_age_group(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_by_age_group(age_grp character varying) RETURNS TABLE(device_name character varying, device_age_group character varying, device_price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, md.age_group, md.price
    FROM medical_devices md
    WHERE md.age_group = devices_by_age_group.age_grp -- Явно указываем, что это параметр функции
    ORDER BY md.price;
END;
$$;


--
-- TOC entry 233 (class 1255 OID 17667)
-- Name: devices_by_manufacturer(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_by_manufacturer(manuf_name character varying) RETURNS TABLE(name character varying, release_date date, price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, md.release_date, md.price
    FROM medical_devices md
    JOIN manufacturers m ON md.manufacturer_id = m.manufacturer_id
    WHERE m.name = manuf_name
    ORDER BY md.release_date;
END;
$$;


--
-- TOC entry 235 (class 1255 OID 17669)
-- Name: devices_by_release_date(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_by_release_date(target_date date) RETURNS TABLE(name character varying, manufacturer character varying, price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, m.name, md.price
    FROM medical_devices md
    LEFT JOIN manufacturers m ON md.manufacturer_id = m.manufacturer_id
    WHERE md.release_date = target_date
    ORDER BY md.name;
END;
$$;


--
-- TOC entry 230 (class 1255 OID 17664)
-- Name: devices_by_sale_date(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_by_sale_date() RETURNS TABLE(name character varying, sale_date date, price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, s.sale_date, s.sale_price
    FROM sales s
    JOIN medical_devices md ON s.device_id = md.device_id
    ORDER BY s.sale_date;
END;
$$;


--
-- TOC entry 236 (class 1255 OID 17670)
-- Name: devices_manuf_sales_in_period(character varying, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_manuf_sales_in_period(manuf_name character varying, start_date date, end_date date) RETURNS TABLE(name character varying, sale_date date, price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, s.sale_date, s.sale_price
    FROM sales s
    JOIN medical_devices md ON s.device_id = md.device_id
    JOIN manufacturers m ON md.manufacturer_id = m.manufacturer_id
    WHERE m.name = manuf_name AND s.sale_date BETWEEN start_date AND end_date
    ORDER BY s.sale_date;
END;
$$;


--
-- TOC entry 232 (class 1255 OID 17666)
-- Name: devices_price_range(numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_price_range(min_price numeric, max_price numeric) RETURNS TABLE(name character varying, price numeric, manufacturer character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, md.price, m.name
    FROM medical_devices md
    LEFT JOIN manufacturers m ON md.manufacturer_id = m.manufacturer_id
    WHERE md.price BETWEEN min_price AND max_price
    ORDER BY md.price;
END;
$$;


--
-- TOC entry 254 (class 1255 OID 17678)
-- Name: devices_sold_to_client_in_period(character varying, date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_sold_to_client_in_period(client_name character varying, start_date date, end_date date) RETURNS TABLE(device_name character varying, sale_date date, price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT md.name, s.sale_date, s.sale_price
    FROM sales s
    JOIN clients cl ON s.client_id = cl.client_id
    JOIN medical_devices md ON s.device_id = md.device_id
    WHERE cl.client_name = devices_sold_to_client_in_period.client_name -- Явно указываем параметр
      AND s.sale_date BETWEEN start_date AND end_date
    ORDER BY s.sale_date;
END;
$$;


--
-- TOC entry 253 (class 1255 OID 17672)
-- Name: devices_supplier_above_avg_city(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.devices_supplier_above_avg_city(supplier_name character varying, city_name character varying) RETURNS TABLE(name character varying, price numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_city_price NUMERIC;
BEGIN
    -- Вычисляем среднюю цену изделий, поступивших из указанного города
    SELECT AVG(md2.price) INTO avg_city_price
    FROM medical_devices md2
    JOIN suppliers sp ON md2.supplier_id = sp.supplier_id
    JOIN cities ct ON sp.city_id = ct.city_id
    WHERE ct.city_name = devices_supplier_above_avg_city.city_name; -- Явно указываем, что это параметр функции

    -- Возвращаем изделия от указанного поставщика, цена которых выше средней по городу
    RETURN QUERY
    SELECT md.name, md.price
    FROM medical_devices md
    JOIN suppliers sp ON md.supplier_id = sp.supplier_id
    WHERE sp.name = supplier_name AND md.price > avg_city_price
    ORDER BY md.price;
END;
$$;


--
-- TOC entry 234 (class 1255 OID 17668)
-- Name: expensive_share(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.expensive_share(threshold numeric) RETURNS real
    LANGUAGE plpgsql
    AS $$
DECLARE
    expensive_count REAL;
    total_count REAL;
BEGIN
    SELECT COUNT(*) INTO expensive_count FROM medical_devices WHERE price > threshold;
    SELECT COUNT(*) INTO total_count FROM medical_devices;
    RETURN expensive_count / total_count;
END;
$$;


--
-- TOC entry 237 (class 1255 OID 17671)
-- Name: sales_share_in_period(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sales_share_in_period(start_date date, end_date date) RETURNS real
    LANGUAGE plpgsql
    AS $$
DECLARE
    period_count REAL;
    total_count REAL;
BEGIN
    SELECT COUNT(*) INTO period_count FROM sales WHERE sale_date BETWEEN start_date AND end_date;
    SELECT COUNT(*) INTO total_count FROM sales;
    RETURN period_count / total_count;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 17591)
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
    city_id integer NOT NULL,
    city_name character varying(100) NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 17590)
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cities_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 217
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cities_city_id_seq OWNED BY public.cities.city_id;


--
-- TOC entry 224 (class 1259 OID 17622)
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    client_id integer NOT NULL,
    client_name character varying(100) NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 17621)
-- Name: clients_client_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clients_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5043 (class 0 OID 0)
-- Dependencies: 223
-- Name: clients_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clients_client_id_seq OWNED BY public.clients.client_id;


--
-- TOC entry 220 (class 1259 OID 17598)
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.manufacturers (
    manufacturer_id integer NOT NULL,
    name character varying(100) NOT NULL,
    city_id integer
);


--
-- TOC entry 219 (class 1259 OID 17597)
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.manufacturers_manufacturer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 219
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.manufacturers_manufacturer_id_seq OWNED BY public.manufacturers.manufacturer_id;


--
-- TOC entry 226 (class 1259 OID 17629)
-- Name: medical_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medical_devices (
    device_id integer NOT NULL,
    name character varying(200) NOT NULL,
    release_date date,
    manufacturer_id integer,
    supplier_id integer,
    price numeric(10,2),
    acquisition_date date,
    age_group character varying(20),
    is_defective boolean DEFAULT false
);


--
-- TOC entry 225 (class 1259 OID 17628)
-- Name: medical_devices_device_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.medical_devices_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5049 (class 0 OID 0)
-- Dependencies: 225
-- Name: medical_devices_device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.medical_devices_device_id_seq OWNED BY public.medical_devices.device_id;


--
-- TOC entry 228 (class 1259 OID 17647)
-- Name: sales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales (
    sale_id integer NOT NULL,
    device_id integer,
    client_id integer,
    sale_date date,
    sale_price numeric(10,2)
);


--
-- TOC entry 227 (class 1259 OID 17646)
-- Name: sales_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sales_sale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5052 (class 0 OID 0)
-- Dependencies: 227
-- Name: sales_sale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sales_sale_id_seq OWNED BY public.sales.sale_id;


--
-- TOC entry 222 (class 1259 OID 17610)
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suppliers (
    supplier_id integer NOT NULL,
    name character varying(100) NOT NULL,
    city_id integer
);


--
-- TOC entry 221 (class 1259 OID 17609)
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suppliers_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 221
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suppliers_supplier_id_seq OWNED BY public.suppliers.supplier_id;


--
-- TOC entry 4852 (class 2604 OID 17594)
-- Name: cities city_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities ALTER COLUMN city_id SET DEFAULT nextval('public.cities_city_id_seq'::regclass);


--
-- TOC entry 4855 (class 2604 OID 17625)
-- Name: clients client_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients ALTER COLUMN client_id SET DEFAULT nextval('public.clients_client_id_seq'::regclass);


--
-- TOC entry 4853 (class 2604 OID 17601)
-- Name: manufacturers manufacturer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers ALTER COLUMN manufacturer_id SET DEFAULT nextval('public.manufacturers_manufacturer_id_seq'::regclass);


--
-- TOC entry 4856 (class 2604 OID 17632)
-- Name: medical_devices device_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_devices ALTER COLUMN device_id SET DEFAULT nextval('public.medical_devices_device_id_seq'::regclass);


--
-- TOC entry 4858 (class 2604 OID 17650)
-- Name: sales sale_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales ALTER COLUMN sale_id SET DEFAULT nextval('public.sales_sale_id_seq'::regclass);


--
-- TOC entry 4854 (class 2604 OID 17613)
-- Name: suppliers supplier_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('public.suppliers_supplier_id_seq'::regclass);


--
-- TOC entry 5023 (class 0 OID 17591)
-- Dependencies: 218
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cities (city_id, city_name) FROM stdin;
1	Москва
2	Санкт-Петербург
3	Новосибирск
4	Екатеринбург
5	Казань
6	Омск
7	Новый город
8	Ќ®ўл© Ј®а®¤
9	Новый город
10	Новый город
11	Новый город
\.


--
-- TOC entry 5029 (class 0 OID 17622)
-- Dependencies: 224
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clients (client_id, client_name) FROM stdin;
1	Клиника №1
2	Горбольница №5
3	Фармкомпания Альфа
4	Сеть аптек "Здоровье"
5	Институт биомедицины
6	Медцентр "Надежда"
7	Региональный госпиталь
9	Тестовый клиент 2
\.


--
-- TOC entry 5025 (class 0 OID 17598)
-- Dependencies: 220
-- Data for Name: manufacturers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.manufacturers (manufacturer_id, name, city_id) FROM stdin;
1	MedTech Corp	1
2	HealthInnovate	2
3	BioEquip Ltd	3
4	NovaMed	4
5	EuroMedix	5
999	Производитель без изделий	1
\.


--
-- TOC entry 5031 (class 0 OID 17629)
-- Dependencies: 226
-- Data for Name: medical_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.medical_devices (device_id, name, release_date, manufacturer_id, supplier_id, price, acquisition_date, age_group, is_defective) FROM stdin;
1	Пульсоксиметр PM100	2024-01-10	1	1	12000.00	2024-02-01	18+	f
2	Тонометр BP200	2023-11-05	2	2	8500.00	2024-01-15	3+	f
3	Суточный монитор АД BPro	2024-03-20	3	3	4500.00	2024-04-10	6+	f
4	Отоларингологический набор ЛОР-7	2024-08-12	4	4	15000.00	2024-09-01	3+	t
5	Неврологический молоточек HM-3	2024-05-18	5	5	210000.00	2024-06-01	18+	f
6	Термометр цифровой DT-50	2024-02-14	1	2	2200.00	2024-03-01	3+	f
7	ЭКГ-аппарат CardioPro	2023-10-30	2	3	320000.00	2023-11-20	18+	f
8	Спирометр SpiroMax	2024-04-01	3	4	18500.00	2024-04-25	12+	f
9	Небулайзер NebuCare	2023-12-10	4	5	7500.00	2024-01-05	3+	f
10	Монитор пациента VitalSign	2024-01-25	5	1	420000.00	2024-02-20	18+	f
11	Аппарат для проверки слуха AudioScreen	2023-09-18	1	3	95000.00	2023-10-10	18+	f
12	Дозиметр RadSafe	2024-03-01	2	4	65000.00	2024-03-20	18+	t
13	Кислородный концентратор OxyGen	2023-11-22	3	5	120000.00	2023-12-15	6+	f
14	Пульсоксиметр детский	2024-02-05	4	1	2500000.00	2024-03-01	18+	f
15	Стерилизатор SteamClean	2024-04-12	5	2	88000.00	2024-05-01	18+	f
16	УЗИ-аппарат EchoScan	2024-08-30	1	4	1800000.00	2024-09-25	18+	f
17	Светоскоп Classic S5	2024-05-05	2	5	310000.00	2024-06-01	18+	f
18	Тонометр автоматический	2024-01-12	3	1	300.00	2024-01-20	3+	f
19	Небулайзер Omron CompAir C28	2023-10-10	4	2	11000.00	2023-11-01	12+	t
20	Медицинская маска ProtectAir	2024-03-01	5	3	50.00	2024-03-05	3+	f
21	Неизвестный прибор X1	2024-01-01	\N	\N	5000.00	2024-01-10	18+	f
22	Устройство Y2 (без поставщика)	2023-12-05	1	\N	7000.00	2023-12-15	18+	f
23	Устройство Z3 (без производителя)	2024-02-20	\N	2	9000.00	2024-03-01	18+	f
24	Прототип Alpha	2024-04-10	\N	\N	12000.00	2024-04-15	18+	t
25	Старый аппарат	2024-01-01	\N	\N	2000.00	2024-02-01	18+	f
26	Экспериментальный датчик	2024-05-01	\N	\N	3500.00	2024-05-10	18+	f
27	Безымянный анализатор	2024-11-11	\N	\N	40000.00	2024-12-01	18+	f
28	Нераспознанное изделие	2024-03-15	\N	\N	600.00	2024-03-20	3+	f
29	Устаревший монитор	2024-06-01	\N	\N	18000.00	2024-07-01	18+	t
30	Дубликат устройства	2024-01-28	\N	\N	2500.00	2024-02-10	6+	f
34	Ђ­ «Ё§ в®а ­®ўл©	\N	\N	\N	16000.00	2025-12-14	\N	f
35	Анализатор новый	\N	\N	\N	16000.00	2025-12-23	\N	f
\.


--
-- TOC entry 5033 (class 0 OID 17647)
-- Dependencies: 228
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales (sale_id, device_id, client_id, sale_date, sale_price) FROM stdin;
1	1	1	2024-02-10	12000.00
2	2	2	2024-01-20	8500.00
3	3	3	2024-04-15	4500.00
4	4	4	2024-09-10	15000.00
5	5	5	2024-06-10	210000.00
6	6	6	2024-03-05	2200.00
7	7	7	2023-12-01	320000.00
8	8	1	2024-05-01	18500.00
9	9	2	2024-01-10	7500.00
10	10	3	2024-03-10	420000.00
11	11	4	2023-10-20	95000.00
12	12	5	2024-04-01	65000.00
13	13	6	2023-12-20	120000.00
14	14	7	2024-03-15	2500000.00
15	15	1	2024-05-10	88000.00
16	16	2	2023-10-10	1800000.00
17	17	3	2024-06-15	310000.00
18	18	4	2024-01-25	300.00
19	19	5	2023-11-15	11000.00
20	20	6	2024-03-10	50.00
21	1	7	2024-07-01	11800.00
22	2	1	2024-02-05	8300.00
23	3	2	2024-05-01	4400.00
24	5	3	2024-08-01	205000.00
25	6	4	2024-04-01	2150.00
26	7	5	2024-01-10	315000.00
27	8	6	2024-06-01	18200.00
28	9	7	2024-02-01	7300.00
29	10	1	2024-04-01	410000.00
30	11	2	2024-11-01	94000.00
31	12	3	2024-05-01	64000.00
32	13	4	2024-01-10	118000.00
33	14	5	2024-04-01	2450000.00
\.


--
-- TOC entry 5027 (class 0 OID 17610)
-- Dependencies: 222
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.suppliers (supplier_id, name, city_id) FROM stdin;
1	MedSupply GmbH	1
2	RusMed Distribution	2
3	Siberian MedTrade	3
4	UralMed	4
5	VolgaMed	5
\.


--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 217
-- Name: cities_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cities_city_id_seq', 11, true);


--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 223
-- Name: clients_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.clients_client_id_seq', 9, true);


--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 219
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.manufacturers_manufacturer_id_seq', 5, true);


--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 225
-- Name: medical_devices_device_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.medical_devices_device_id_seq', 35, true);


--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 227
-- Name: sales_sale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sales_sale_id_seq', 33, true);


--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 221
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.suppliers_supplier_id_seq', 5, true);


--
-- TOC entry 4860 (class 2606 OID 17596)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- TOC entry 4866 (class 2606 OID 17627)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- TOC entry 4862 (class 2606 OID 17603)
-- Name: manufacturers manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (manufacturer_id);


--
-- TOC entry 4868 (class 2606 OID 17635)
-- Name: medical_devices medical_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_devices
    ADD CONSTRAINT medical_devices_pkey PRIMARY KEY (device_id);


--
-- TOC entry 4870 (class 2606 OID 17652)
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (sale_id);


--
-- TOC entry 4864 (class 2606 OID 17615)
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- TOC entry 4871 (class 2606 OID 17604)
-- Name: manufacturers manufacturers_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id);


--
-- TOC entry 4873 (class 2606 OID 17636)
-- Name: medical_devices medical_devices_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_devices
    ADD CONSTRAINT medical_devices_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturers(manufacturer_id);


--
-- TOC entry 4874 (class 2606 OID 17641)
-- Name: medical_devices medical_devices_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medical_devices
    ADD CONSTRAINT medical_devices_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id);


--
-- TOC entry 4875 (class 2606 OID 17658)
-- Name: sales sales_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id);


--
-- TOC entry 4876 (class 2606 OID 17653)
-- Name: sales sales_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.medical_devices(device_id);


--
-- TOC entry 4872 (class 2606 OID 17616)
-- Name: suppliers suppliers_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id);


--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE cities; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.cities TO user1;
GRANT SELECT,INSERT ON TABLE public.cities TO operator1;
GRANT SELECT,INSERT,UPDATE ON TABLE public.cities TO analyst1;


--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 217
-- Name: SEQUENCE cities_city_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT USAGE ON SEQUENCE public.cities_city_id_seq TO operator1;
GRANT USAGE ON SEQUENCE public.cities_city_id_seq TO analyst1;
GRANT USAGE ON SEQUENCE public.cities_city_id_seq TO user1;


--
-- TOC entry 5042 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE clients; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT ON TABLE public.clients TO operator1;
GRANT SELECT,INSERT,UPDATE ON TABLE public.clients TO analyst1;
GRANT SELECT ON TABLE public.clients TO user1;


--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE clients_client_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT USAGE ON SEQUENCE public.clients_client_id_seq TO operator1;
GRANT USAGE ON SEQUENCE public.clients_client_id_seq TO analyst1;
GRANT USAGE ON SEQUENCE public.clients_client_id_seq TO user1;


--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE manufacturers; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.manufacturers TO user1;
GRANT SELECT,INSERT ON TABLE public.manufacturers TO operator1;
GRANT SELECT,INSERT,UPDATE ON TABLE public.manufacturers TO analyst1;


--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE manufacturers_manufacturer_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT USAGE ON SEQUENCE public.manufacturers_manufacturer_id_seq TO operator1;
GRANT USAGE ON SEQUENCE public.manufacturers_manufacturer_id_seq TO analyst1;
GRANT USAGE ON SEQUENCE public.manufacturers_manufacturer_id_seq TO user1;


--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE medical_devices; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.medical_devices TO user1;
GRANT SELECT ON TABLE public.medical_devices TO operator1;
GRANT SELECT,INSERT,UPDATE ON TABLE public.medical_devices TO analyst1;


--
-- TOC entry 5050 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE medical_devices_device_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT USAGE ON SEQUENCE public.medical_devices_device_id_seq TO operator1;
GRANT USAGE ON SEQUENCE public.medical_devices_device_id_seq TO analyst1;
GRANT USAGE ON SEQUENCE public.medical_devices_device_id_seq TO user1;


--
-- TOC entry 5051 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE sales; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.sales TO user1;
GRANT SELECT ON TABLE public.sales TO operator1;
GRANT SELECT,INSERT,UPDATE ON TABLE public.sales TO analyst1;


--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 227
-- Name: SEQUENCE sales_sale_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT USAGE ON SEQUENCE public.sales_sale_id_seq TO operator1;
GRANT USAGE ON SEQUENCE public.sales_sale_id_seq TO analyst1;
GRANT USAGE ON SEQUENCE public.sales_sale_id_seq TO user1;


--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE suppliers; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE public.suppliers TO user1;
GRANT SELECT,INSERT ON TABLE public.suppliers TO operator1;
GRANT SELECT,INSERT,UPDATE ON TABLE public.suppliers TO analyst1;


--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE suppliers_supplier_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT USAGE ON SEQUENCE public.suppliers_supplier_id_seq TO operator1;
GRANT USAGE ON SEQUENCE public.suppliers_supplier_id_seq TO analyst1;
GRANT USAGE ON SEQUENCE public.suppliers_supplier_id_seq TO user1;


-- Completed on 2026-04-01 17:18:52

--
-- PostgreSQL database dump complete
--

\unrestrict TBrX9a5p37OHgID2uIUfV81wvFMISOXtyaWscbs6lTv4Am62y9wC4r4SmSEdzfB

