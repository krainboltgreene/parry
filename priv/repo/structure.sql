--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2
-- Dumped by pg_dump version 14.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: creators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creators (
    id uuid NOT NULL,
    name text NOT NULL,
    external_streamer_id text NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id uuid NOT NULL,
    content text NOT NULL,
    external_chatroom_id text NOT NULL,
    external_sender_id text NOT NULL,
    external_message_id text NOT NULL,
    written_at timestamp(0) without time zone NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    id uuid NOT NULL,
    external_chatroom_id text NOT NULL,
    creator_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: creators creators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creators
    ADD CONSTRAINT creators_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: creators_external_streamer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX creators_external_streamer_id_index ON public.creators USING btree (external_streamer_id);


--
-- Name: messages_external_chatroom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_external_chatroom_id_index ON public.messages USING btree (external_chatroom_id);


--
-- Name: messages_external_message_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX messages_external_message_id_index ON public.messages USING btree (external_message_id);


--
-- Name: messages_external_sender_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX messages_external_sender_id_index ON public.messages USING btree (external_sender_id);


--
-- Name: rooms_creator_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX rooms_creator_id_index ON public.rooms USING btree (creator_id);


--
-- Name: rooms_external_chatroom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rooms_external_chatroom_id_index ON public.rooms USING btree (external_chatroom_id);


--
-- Name: messages messages_external_chatroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_external_chatroom_id_fkey FOREIGN KEY (external_chatroom_id) REFERENCES public.rooms(external_chatroom_id);


--
-- Name: rooms rooms_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20230626052739);
INSERT INTO public."schema_migrations" (version) VALUES (20230626052834);
INSERT INTO public."schema_migrations" (version) VALUES (20230626052839);
