DROP TABLE IF EXISTS spolecznosci CASCADE;
DROP TABLE IF EXISTS wydarzenia_spolecznosci CASCADE;
DROP TABLE IF EXISTS rodzaje_wydarzen CASCADE;
DROP TABLE IF EXISTS wydarzenia CASCADE;
DROP TABLE IF EXISTS czlonkowie_spolecznosci CASCADE;
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS edycje CASCADE;
DROP TABLE IF EXISTS sale CASCADE;
DROP TABLE IF EXISTS zaimki CASCADE;
DROP TABLE IF EXISTS czlonkowie CASCADE;
DROP TABLE IF EXISTS czlonkowie_archiwum CASCADE;
DROP TABLE IF EXISTS czlonkowie_edycje CASCADE;
DROP TABLE IF EXISTS edycje_sale CASCADE;
DROP TABLE IF EXISTS prelekcje CASCADE;
DROP TABLE IF EXISTS dlugosci CASCADE;
DROP TABLE IF EXISTS prelegenci CASCADE;
DROP TABLE IF EXISTS prelekcje_prelegenci CASCADE;
DROP TABLE IF EXISTS posty CASCADE;
DROP TABLE IF EXISTS posty_archiwum CASCADE;
DROP TABLE IF EXISTS wolontariusze CASCADE;
DROP TABLE IF EXISTS organizatorzy CASCADE;
DROP TABLE IF EXISTS adresy CASCADE;
DROP TABLE IF EXISTS wolontariusze_prelekcje CASCADE;
drop function get_user_id;
drop function register;
drop function make_post;
drop function get_posts;
drop function get_user_posts_with_names;
drop function get_communities_with_names;
drop function get_replies;
drop function register_as_volonteer;
drop function register_as_speaker;
drop function get_community_members;
drop function count_members;
drop function count_posts;
drop function get_volonteers;
drop function get_communities;
drop function get_editions;
drop function count_participants;
drop function intersects;
drop function register_talk;
drop function add_to_talk;
drop function get_timestable;
drop function generate_attendee_badges;
drop function generate_volonteer_badges;
drop function generate_organiser_badges;
drop function generate_speaker_badges;
drop function register_trigger;
drop function post_trigger;
drop function volo_trigger;
drop function archive;
drop function prelegent_trigger;
drop function czlonkowie_trigger;
drop function ce_trigger;
drop function wp_trigger;
drop function wolontariusze_trigger;
drop function wolontariusze_delete_trigger;
drop function ce_delete_trigger;
drop function prelekcja_delete_trigger;
drop function prelegent_delete_trigger;
drop function czlonkowie_delete_trigger;
