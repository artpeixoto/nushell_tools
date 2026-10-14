use ../wrappers/attractorr.nu ;
use std/assert;
use ../env_utils/default_env.nu  ;

export-env {
	default_env {
		torrent: {
			categories: [
				movie
				show
				book
				games
				application
				misc
			]
		}
		dest:  {
			paths_by_categories: {
				movie: "Movies",
				show:  "Shows",
				book: "Books",
				application:  "Download",
				games: "Games",
				misc: "Download"
			}
			base_path: "/mnt/Windows-SSD/Media/"
		},

		downloader:{
			application: "transmission",
			url: "http://127.0.0.1:9091/transmission/rpc"
		}
	}
}
export def main [query: oneof<nothing,string>, --category: string, --dest_path: path] {
	assert (($category | is-empty ) or ($dest_path | is-empty)) "category and dest_path cannot be both defined"

  	let query = $query | default {input }

}

export const categories = [

];

export def pick_a_category [] : nothing -> string {
	$categories | input list "Pick a category, please"
}

export def get_dest_path_of_category [category: oneof<nothing, string>] : nothing -> path {
  let child_dir = match $category {
    "movie" => "Movies",
    'show'  => "Shows",
    'book'  => "Books",
    'application'  => "Downloads",
     null  => "Downloads",
     $a => {error make $"unknown category: ($a)"}
  };
  
  $env.torrent.dest.base_path | path join $child_dir;
}
