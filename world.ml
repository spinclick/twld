open Extensions.Pervasives ;; 

exception Wld_version_unsupported of string ;;
exception Read_type_unsupported of string ;;
exception Unknown_array_size_type of string ;;
let supported_wld_version = 156;;

type array_size =
  | Static of int (* fixed number of elements *)
  | Variable of string (* Use string as key to the number of elements *) ;;

type read_type = 
  | Bool | Byte 
  | Int16 | Int32 | Int64
  | Single | Double
  | Array of (read_type * array_size)
  | String ;;

type header_value = 
  | HBool of bool 
  | HByte of int
  | HInt of int64
  | HFloat of float
  | HArray of header_value array
  | HString of string ;;

type header_pair = (string * header_value) ;;
type header = header_pair list ;;

type x = int ;;
type y = int ;;
type wall_type = int ;;
type tile_color = NoColor | Color of int ;;
type tile_liquid = NoLiquid | Water | Honey | Lava ;;
type tile_wall  = NoWall | Wall of (wall_type * tile_color) ;;
type tile_frame = NoFrame | Frame of (x * y) ;; 
type tile_wire = NoWire | Wire1 | Wire2 | Wire3 | Wire4
type tile_form = Slope of int | NoSlope | HalfBrick ;;

type tile_background = 
  { wire : tile_wire ;
    wall : tile_wall ;
    actuator : bool ;
    inactive : bool } ;;

type tile_solid =
  { tile_type : int ;
    color : tile_color ;
    frame : tile_frame ;
    form : tile_form ;
    background: tile_background } ;;

type tile = 
    Solid of tile_solid 
  | Liquid of tile_liquid 
  | Empty of tile_background ;;

type tiles = tile array array ;;

type position = 
  { x : int ;
    y : int } ;;

type item = 
 { id : int ;
   prefix : int } ;;

type chest = 
  { pos : position ;
    name : string ;
    items : item array } ;;

type sign = 
  { pos : position ;
    text : string } ;;

type entity = 
  { pos: position ;
    id: int; } ;;

type npc = 
  { active : bool ;
    name : string ;
    displayName : string ;
    positionX : string ;
    positionY : string ;
    homeless : bool ;
    homeTileX : int ;
    homeTileY : int } ;;

type pressure_plate = { pos: position } ;;

type world = 
  { header: header ;
    tiles: tiles ;
    chests: chest array ;
    signs: sign array ;
    npcs : npc array ;
    entities: entity array ;
    pressure_plates: pressure_plate array } ;;

let rec byte_size_of_type = function
  | Bool | Byte -> 1
  | Int16 -> 2
  | Int32 | Single -> 4
  | Int64 | Double -> 8
  | Array (t, Static array_size) -> 
      (byte_size_of_type t) * array_size 
  | String | _ -> 0 ;;

type header_read_pairs_t = (string * read_type ) list ;;
let header_pairs = [
   ("version", Int32); 
   ("relogic", Int64);
   ("revision", Int32);
   ("favorite", Int64);
   ("_num_position", Int16);
   ("positions", Array (Int32, Static 10));
   ("_num_importance", Int16);
   ("importance", Array (Bool, Static 58));

   ("world_name", String);
   ("world_id", Int32);
   ("left_world_boundary", Int32);
   ("right_world_boundary", Int32);
   ("top_world_boundary", Int32);
   ("bottom_world_boundary", Int32);
   ("max_tiles_y", Int32);
   ("max_tiles_x", Int32);
   ("expert_mode", Bool);
   ("creation_time", Double);
   ("moon_type", Byte);
   ("tree_x", Array (Int32, Static 3)); (* size = 3 *)
   ("tree_style", Array (Int32, Static 4)); (* size = 4 *)
   ("cave_back_x", Array (Int32, Static 3)); (* size = 3 *)
   ("cave_back_style", Array (Int32, Static 4)); (* size = 4 *)
   ("ice_back_style", Int32);
   ("jungle_back_style", Int32);
   ("hell_back_style", Int32);
   ("spawn_tile_x", Int32);
   ("spawn_tile_y", Int32);
   ("world_surface", Double);
   ("rock_layer", Double);
   ("temp_time", Double);
   ("temp_day_time", Bool);
   ("temp_moon_phase", Int32);
   ("temp_blood_moon", Bool);
   ("temp_eclipse", Bool);
   ("dungeon_x", Int32);
   ("dungeon_y", Int32);
   ("crimson", Bool);

   ("downed_boss_1", Bool);
   ("downed_boss_2", Bool);
   ("downed_boss_3", Bool);
   ("downed_queen_bee", Bool);
   ("downed_mech_boss_1", Bool);
   ("downed_mech_boss_2", Bool);
   ("downed_mech_boss_3", Bool);
   ("downed_mech_boss_any", Bool);
   ("downed_plant_boss", Bool);
   ("downed_golem_boss", Bool);
   ("downed_slime_king", Bool);
   ("saved_goblin", Bool);
   ("saved_wizard", Bool);
   ("saved_mech", Bool);
   ("downed_goblins", Bool);
   ("downed_clown", Bool);
   ("downed_frost", Bool);
   ("downed_pirates", Bool);
   ("shadow_orb_smashed", Bool);
   ("spawn_meteor", Bool);
   ("shadow_orb_count", Byte);
   ("altar_count", Int32);
   ("hard_mode", Bool);
   ("invasion_delay", Int32);
   ("invasion_size", Int32);
   ("invasion_type", Int32);
   ("invasion_x", Double);

   ("slime_rain_time", Double);
   ("sundial_cooldown", Byte);
   ("temp_raining", Bool);
   ("temp_rain_time", Int32);
   ("temp_max_rain", Single);
   ("ore_tier1", Int32);
   ("ore_tier2", Int32);
   ("ore_tier3", Int32);
   ("tree_bg", Byte);
   ("corrupt_bg", Byte);
   ("jungle_bg", Byte);
   ("snow_bg", Byte);
   ("hallow_bg", Byte);
   ("crimson_bg", Byte);
   ("desert_bg", Byte);
   ("ocean_bg", Byte);
   ("cloud_bg_active", Int32);
   ("num_clouds", Int16);
   ("wind_speed", Single);
   ("_num_angler_finished", Int32);
   ("angler_who_finished_today", Array (String, Variable "_num_angler_finished"));
   ("saved_angler", Bool);
   ("angler_quest", Int32);
   ("saved_stylist", Bool);
   ("saved_tax_collector", Bool);
   ("invasion_size_start", Int32);
   ("temp_cultist_delay", Int32);
   ("_num_npc_killed", Int16);
   ("npc_kill_count", Array (Int32, Variable "_num_npc_killed"));
   ("fast_forward_time", Bool);
   ("downed_fishron", Bool);
   ("downed_martians", Bool);
   ("downed_ancient_cultist", Bool);
   ("downed_moonlord", Bool);
   ("downed_halloween_king", Bool);
   ("downed_halloween_tree", Bool);
   ("downed_christmas_ice_queen", Bool);
   ("downed_christmas_santank", Bool);
   ("downed_christmas_tree", Bool);

   ("downed_tower_solar", Bool);
   ("downed_tower_vortex", Bool);
   ("downed_tower_nebula", Bool);
   ("downed_tower_stardust", Bool);

   ("tower_active_solar", Bool);
   ("tower_active_vortex", Bool);
   ("tower_active_nebula", Bool);
   ("tower_active_stardust", Bool);
   ("lunar_apocalypse_is_up", Bool);
   (* v 170 *)
   ("temp_party_manual", Bool);
   ("temp_party_genuine", Bool);
   ("temp_party_cooldown", Int32);
   ("_num_celebrating", Int32);
   ("temp_party_celebrating_npcs", Array (Int32, Variable "_num_celebrating"));
   (* v 174*)
   ("temp_sandstorm_happening", Bool);
   ("temp_sandstorm_time_left", Int32);
   ("temp_sandstorm_severity", Single);
   ("temp_sandstorm_intended_severity", Single) ] ;;

let read_header_from_pair in_chan (previously_read : header) pair : header =
  let rec data_of_pair = function
    | (key, Int64) -> (key, HInt (read_int64 in_chan))
    | (key, Int32) -> (key, HInt (Int64.of_int32 (read_int32 in_chan)))
    | (key, Int16) -> (key, HInt (Int64.of_int (read_int16 in_chan)))
    | (key, Bool)  -> (key, HBool (read_bool in_chan))
    | (key, Byte)  -> (key, HByte (read_byte in_chan))
    | (key, String) -> (key, HString (read_pascal_string in_chan))
    | (key, Single) -> (key, HFloat (read_single in_chan))
    | (key, Double) -> (key, HFloat (read_double in_chan))
    | (key, Array (Int32, Static n)) -> begin
       let int32s = read_int32_array in_chan n in
       (key, HArray (Array.map (fun i -> HInt (Int64.of_int32 i)) int32s))
     end
    | (key, Array (Bool, Static n)) -> begin
       let bools = read_bool_array in_chan n in
       (key, HArray (Array.map (fun b -> HBool b) bools))
     end
    | (key, Array (String, Static n)) -> begin
       let strings = read_string_array in_chan n in
       (key, HArray (Array.map (fun b -> HString b) strings))
     end
    | (key, Array (t, Variable prior_key)) ->  begin  (* Convert Variable types to Static*)
       let amount = 
         match (List.assoc prior_key previously_read) with
           | HInt d -> Int64.to_int d
           | _ -> raise @@ Unknown_array_size_type key
       in
       (data_of_pair (key, Array (t, Static amount)))
     end
    | (key, _) -> raise @@ Read_type_unsupported key 
  in
  Log.printf Log.Debug "Reading '%s'\n" (fst pair);
  ((data_of_pair pair) :: previously_read) ;;

let read_header inch : header = 
  List.fold_left 
    (read_header_from_pair inch)
    []
    header_pairs ;;

let rec string_of_header_data d = 
  let open Array in
  let sprintf = Printf.sprintf in
  match d with 
    | HBool b -> sprintf "%b" b
    | HByte i -> sprintf "%d" i
    | HInt i64 -> sprintf "%Ld" i64
    | HFloat f -> sprintf "%f" f
    | HArray ar -> "[" ^ (String.concat "," (List.map string_of_header_data (to_list ar))) ^ "]"
    | HString str -> "\"" ^ str ^ "\"" ;;

let print_header_pair p =
  Printf.printf "%s: %s\n" (fst p) (string_of_header_data (snd p)) ;;


(* Better approach: we have a type for the flags, then use small functions to
 * ask what is happening *)

type tile_flags = 
  { b3 : int ;
    b2 : int ;
    b1 : int } ;;

(*
type tile_flags = 
  (* B3 *)
  | TF_HasB2      (* 1 *)
  | TF_TileActive (* 2 *)
  | TF_HasWall    (* 4 *)
  | TF_Liquid     (* 8 *)
  | TF_Int16Tile  (* 32 *)
  | TF_Int8RLE    (* 64 *)
  | TF_Int16RLE   (* 128 *)
  (* B2 *)
  | TF_HasB1      (* 1 *)
  | TF_Wire       (* 2 *)
  | TF_Wire2      (* 4 *)
  | TF_Wire3      (* 8 *)
  | TF_Slope of int (* 16-128 *)
  (* B1 *)
  | TF_Actuator     (* 2 *)
  | TF_Inactive     (* 4 *)
  | TF_HasTileColor (* 8 *)
  | TF_WallHasColor (* 16 *)
  | TF_Wire4        (* 32 *)
  (* Misc *)
  | TF_None
*)

let byte_to_boolbits (byte : int) =
  let (|.|) data bit = data land bit == bit in
  [| byte |.| 1 ;
     byte |.| 2 ;
     byte |.| 4 ;
     byte |.| 8 ;
     byte |.| 16 ;
     byte |.| 32 ;
     byte |.| 64 ;
     byte |.| 128 |] ;;

(* Integer exponent *)
let rec ( ^^ ) base exp =
  if exp = 0 then 1
  else if exp = 1 then base
  else (base*(base ^^ (exp-1))) ;;

let int_of_boolbits arr =
  let sum tosum = Array.fold_left (fun x1 x2 -> x1+x2) 0 tosum in
  sum @@ Array.mapi (fun i x -> if x then (2 ^^ i) else 0) arr ;;

let read_tile_flags in_ch = 
  let flags3 = byte_to_bool_arr @@ input_byte in_ch in
  let flags2 = byte_to_bool_arr @@ if (flags3.(0)) then input_byte in_ch else 0 in
  let flags1 = byte_to_bool_arr @@ if (flags2.(0)) then input_byte in_ch else 0 in
  (flags3,flags2,flags1) ;;

let read_tiles in_ch header = 
  Log.infoln "loading tiles...";
  let max_x = Util.int_of_bytes (List.assoc "max_tiles_x" header) in
  let max_y = Util.int_of_bytes (List.assoc "max_tiles_y" header) in
  let importance = Util.bool_array_of_bits (List.assoc "importance" header) in

  let input_int16 in_ch = 
    let b1 = input_byte in_ch in
    let b2 = input_byte in_ch in
    b1 lor (b2 lsl 8)
  in

  (* A beautiful abstraction over this cluster f*** of a format *)
  let read_tile () =
    (* These flags tell us how many bytes we need to read to extract all the
     * information from this tile *)
    let flags3,flags2,flags1 = read_tile_flags in_ch in
    (* First byte: b3 (everything past this is optional) *)
    let has_tile_active = flags.(1) in
    let has_wall = flags3.(2) in
    let has_liquid = flags3.(3) || flags.(4) in 
    let has_int16_tile = flags3.(6)
    let has_int8_rle = flags3.(6)
    let has_int16_rle = flags3.(7)
    (* Second byte: b2 *)
    let has_wire1 = flags2.(1) in
    let has_wire2 = flags2.(2) in
    let has_wire3 = flags2.(3) in
    let slope = int_of_boolbits [|flags2.(4); flags.(5); flags.(6); flags.(7)|]
    (* Third byte: b1 *)
    let has_actuator = flags1.(1) in
    let has_inactive = flags1.(2) in           (* Is this referring to the actuator? *)
    let has_tile_color = flags1.(3) in
    let has_wall_color = flags1.(4) in
    let has_wire4 = flags1.(5) in

    let tile_type =
      if not (tile_is TF_TileActive) then
        if tile_is TF_Int16Tile 
        then input_int16 in_ch
        else input_byte in_ch
      else 0
    in

    let frame = 
      if importance.(tile_type) 
      then begin 
        let x = input_int16 in_ch in
        let y = input_int16 in_ch in
        Frame (x,y)
      end
      else NoFrame

      in

    let tile_color = 
      if tile_is TF_TileActive 
      then read_color_if TF_HasTileColor 
      else NoColor
    in

    let wall =
      if tile_is TF_HasWall then 
        Wall ((input_byte in_ch),
              (read_color_if TF_WallHasColor))
      else NoWall
    in

    let liquid = 
      if tile_is TF_Liquid then
        match (input_byte in_ch) with 
          | 0 -> Water
          | 1 -> Lava
          | 2 -> Honey
          | _ -> NoLiquid
      else 
        NoLiquid
    in

    let wire = 
      if tile_is TF_Wire then Wire1
      else if tile_is TF_Wire2 then Wire2
      else if tile_is TF_Wire3 then Wire3
      else if tile_is TF_Wire4 then Wire4
      else NoWire
    in

    let form = 
      let d = 
        List.find 
          (function 
            | TF_Slope n -> true 
            | _ -> false)
          flags
      in
      let slope = 
        match d with
          | TF_Slope n -> n
          | _ -> 0
      in
      if slope = 0  (*Note: check if tile type is solid!*)
        then NoSlope
        else if slope == 1 then HalfBrick
        else Slope (slope - 1)
    in

    let actuator = tile_is TF_Actuator in
    let inactive = tile_is TF_Inactive in

    let rle_k = 
      if tile_is TF_Int16RLE then input_int16 in_ch
      else if tile_is TF_Int8RLE then input_byte in_ch
      else 0
    in
    ()
  in

  () ;;

(*let read_tiles in_ch header = 
  Log.infoln "loading tiles...";
  let max_x = Util.int_of_bytes (List.assoc "max_tiles_x" header) in
  let max_y = Util.int_of_bytes (List.assoc "max_tiles_y" header) in
  let importance = Util.bool_array_of_bits (List.assoc "importance" header) in

  let read_wld_tile () =
    let tilebuf = Buffer.create 0 in
    let bit_on bts n = ((int_of_char (Bytes.get bts 0)) land n) = n in
    (*let add_n_bytes n = let b = (single_read inch n) in Buffer.add_bytes tilebuf b ; b in*)
    let add_n_bytes n = 
      for i=0 to n do
        Buffer.add_char tilebuf @@ input_char in_ch
      done
    in
    let add_byte () = add_n_bytes 1 in
    let add_int16 () = add_n_bytes 2 in
    let add_int32 () = add_n_bytes 4 in

    let b3 = add_byte () in
    let b2 = if (bit_on b3 1) then add_byte () else Bytes.make 1 '\000' in
    let b = if (bit_on b2 1) then add_byte () else Bytes.make 1 '\000' in

    let tile_id = begin
      if (bit_on b3 2) then begin (* if active tile *)
        let num2 = (* tile id *)
          (util.int_of_bytes (if (bit_on b3 32) then add_int16 () else add_byte ()))
        in

        if importance.(num2) then ignore(add_int32 ()) (* texture coordinates *)
        else ();

        if bit_on b 8 then ignore(add_byte ()) else (); (* tile color *)
        num2 (* <-- type of tile *)
      end 
        else -1 (* no tile here *)
    end
    in

    if bit_on b3 4 then begin
      ignore(add_byte ()); (* wall type *)
      if bit_on b 16 then ignore(add_byte ()) else (); (* wall color *)
    end else ();

    let b4 = ((util.byte_at b3 0) land 24) lsr 3 in
    if b4 != 0 then ignore(add_byte ()) else ();  (* liquid type *)

    let tile_id = match b4 with  (* treat liquid like a tile *)
      | 1 -> 600      (* water *)
      | 2 -> 700      (* lava *)
      | 3 -> 800      (* honey *)
      | _ -> tile_id  (* no liquid *)
    in

    let b4 = ((util.byte_at b3 0) land 192) lsr 6 in

    (* rle count *)
    let k =  
      match b4 with
        | 0 -> bytes.make 1 '\000'
        | 1 -> add_byte ()
        | _ -> add_int16 () 
    in

    ( (buffer.to_bytes tilebuf) , 
      [ ("rle_length", (util.int_of_bytes k)) ; ("tile_id", tile_id) ] )
  in

  (*let tiles = array.make_matrix max_x max_y (bytes.create 0) in*)
  let tiles = array.make_matrix max_y max_x '\000' in
  for x=0 to (max_x-1) do
    log.printf log.info "loading tile row %d/%d\n" (x+1) max_x;
    (*printf.printf "--> new x: %d (max_x = %d, max_y = %d)\n" x max_x max_y;*)
    let rec for_every_y y =
      if y >= max_y then ()
      else begin
        let tile_data = read_wld_tile () in 
        let tile_bytes = fst tile_data in
        let rle_count = List.assoc "rle_length" (snd tile_data) in
        let tile_id = List.assoc "tile_id" (snd tile_data) in
        let tile_char = Tiles.char_of_tile @@ tiles.tile_of_id tile_id in

        (* log everything here *)
        log.printf log.debug 
          "tid = %3d ; tchr = %c ; k = %3d ; (y=%d,x=%d) ; bytes = [%s\b]\n" 
          tile_id tile_char rle_count y x (log.int_string_of_bytes tile_bytes);

        (* set tile char at y,x *)
        tiles.(y).(x) <- tile_char;

        (* copy tile data rle times down *)
        for y_with_rle=(y+1) to (y+rle_count) do 
          tiles.(y_with_rle).(x) <- tile_char
        done;

        (* continue down column *)
        for_every_y (rle_count + y + 1)
      end 
    in
    for_every_y 0;
  done;
  log.infof " %d tiles\n" (max_y*max_x);
  tiles ;;
*)

let read_chests in_ch = () ;;
let read_signs in_ch = () ;;
let read_npcs in_ch = () ;;
let read_entities in_ch = () ;;
let read_pressure_plates in_ch = () ;;

(* let read_world in_ch =
    let header = read_header in_ch in
    let tiles = read_header in_ch in
    let chests = read_header in_ch in
    let signs = read_header in_ch in
    let npcs = read_header in_ch in
    let entities = read_header in_ch in *)

(* Loading functions*)
let world_of_file path = () ;;
let world_of_buffer bytes = () ;;
(* Saving functions *)
let save_world_to_file world = () ;;
