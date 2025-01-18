%% Book list class - 2122 version (2021-2022)
% Last updated 2021-10-01

% Copyright (c) 2020-21 psvenk

% This Source Code Form is subject to the terms of the Mozilla Public
% License, v. 2.0. If a copy of the MPL was not distributed with this
% file, You can obtain one at https://mozilla.org/MPL/2.0/.

% SPDX-License-Identifier: MPL-2.0

\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3, l3keys2e, xparse}
\ProvidesExplClass {booklist2122} {2021/06/07} {2122} {Book list class}
\LoadClass{article}

\RequirePackageWithOptions{geometry}

\RequirePackage[T1]{fontenc}
\RequirePackage{lmodern}
% https://tex.stackexchange.com/a/377

\RequirePackage{array, booktabs, longtable, cellspace, colortbl}

\cellspacetoplimit 2.5pt

\prop_new:N \g_booklist_config_prop
\prop_new:N \g_booklist_attribute_names_prop
\prop_new:N \g_booklist_attribute_colors_prop

\bool_new:N \g_booklist_isfirstrow_bool
\bool_set_true:N \g_booklist_isfirstrow_bool

\keys_define:nn {booklist_config} {
	title        .prop_put:N         = \g_booklist_config_prop,
	title        .value_required:n   = true,
	author       .prop_put:N         = \g_booklist_config_prop,
	author       .value_required:n   = true,
	oldstylenums .prop_put:N         = \g_booklist_config_prop,
	oldstylenums .default:n          = {\oldstylenums},
	liningnums   .prop_put:N         = \g_booklist_config_prop,
	liningnums   .default:n          = {},
	unknowncolor .prop_put:N         = \g_booklist_config_prop,
	unknowncolor .default:n          = {red},
}

\NewDocumentCommand \booklistconfig {m} {
	\keys_set:nn {booklist_config} {#1}
}

\NewDocumentCommand \booklistattributenames {m} {
	\prop_gset_from_keyval:Nn \g_booklist_attribute_names_prop {#1}
}

\NewDocumentCommand \booklistattributecolors {m} {
	\prop_gset_from_keyval:Nn \g_booklist_attribute_colors_prop {#1}
}

\NewDocumentEnvironment {booklist} {O{6.75cm}O{3.25cm}O{2.5cm}} {
	\int_gzero_new:N \g_booklist_count_int
	\int_gzero_new:N \g_booklist_currentyear_int
	\begin{longtable}{
		r
		>{\raggedright\arraybackslash} p{#1}
		>{\raggedright\arraybackslash} p{#2}
		>{\raggedright\arraybackslash} p{#3}
	}
		\toprule
		\multicolumn{1}{c}{\textbf{\#}} &
		\multicolumn{1}{c}{\textbf{Title}} &
		\multicolumn{1}{c}{\textbf{Author}} &
		\multicolumn{1}{c}{\textbf{Date}}
		\\\midrule
		\endhead
} {
	\\\bottomrule
	\end{longtable}
}

\seq_new:N \l_booklist_attributes_seq
\cs_new:Nn \booklist_format_title:N {
	% #1: prop with book information
	\prop_get:NnNT #1 {attributes} \l_tmpa_tl {
		(
		\seq_set_split:NnV \l_booklist_attributes_seq {,} \l_tmpa_tl
		\bool_until_do:nn {\seq_if_empty_p:N \l_booklist_attributes_seq} {
			\seq_pop_left:NNT \l_booklist_attributes_seq \l_tmpa_tl
			{
				{
					\prop_map_inline:Nn \g_booklist_attribute_colors_prop {
						\str_if_eq:NNT \l_tmpa_tl {##1} {
							\color{##2}
						}
					}
					\tl_use:N \l_tmpa_tl
				}
				\prop_map_inline:Nn \g_booklist_attribute_names_prop {
					\str_if_eq:NNT \l_tmpa_tl {##1} {
						\footnote{##2}
						\prop_gremove:Nn \g_booklist_attribute_names_prop {##1}
					}
				}
			}
			\seq_if_empty:NF \l_booklist_attributes_seq {;~}
		}
		) ~
	}
	\prop_if_in:NnTF #1 {title}
		{
			\prop_get:NnNT #1 {title} \l_tmpa_tl
				{\tl_use:N \l_tmpa_tl}
		}
		{\multicolumn{1}{c}{(No~Title)}}
	\bool_lazy_or:nnT
		{\prop_if_in_p:Nn #1 {isbn}}
		{\prop_if_in_p:Nn #1 {bookdate}}
	{
		{~} (
		\prop_get:NnNT #1 {bookdate} \l_tmpa_tl {
			\tl_use:N \l_tmpa_tl
			\prop_get:NnNT #1 {isbn} \l_tmpb_tl {;~}
		}
		\prop_get:NnNT #1 {isbn} \l_tmpb_tl {
			\textsc{
				isbn:
				\prop_get:NnNT \g_booklist_config_prop {oldstylenums}
					\l_tmpa_tl
					{\tl_use:N \l_tmpa_tl}
				{\tl_use:N \l_tmpb_tl}
			}
		}
		)
	}
	\prop_if_in:NnT #1 {dewey}
		{
			{~}
			\prop_get:NnNT #1 {dewey} \l_tmpb_tl {
				\textsc{
					dds:
					\prop_get:NnNT \g_booklist_config_prop {oldstylenums}
						\l_tmpa_tl
						{\tl_use:N \l_tmpa_tl}
					{\tl_use:N \l_tmpb_tl}
				}
			}
		}
}

\cs_new:Nn \booklist_format_author:N {
	% #1: prop with book information
	\prop_if_in:NnTF #1 {author}
		{
			\prop_get:NnNT #1 {author} \l_tmpa_tl
				{\tl_use:N \l_tmpa_tl}
		}
		{\multicolumn{1}{c}{(No~Author)}}
}

\int_new:N \l_booklist_datea_year_int
\int_new:N \l_booklist_datea_month_int
\int_new:N \l_booklist_datea_day_int
\bool_new:N \l_booklist_datea_approx_bool
\int_new:N \l_booklist_dateb_year_int
\int_new:N \l_booklist_dateb_month_int
\int_new:N \l_booklist_dateb_day_int
\bool_new:N \l_booklist_dateb_approx_bool
\bool_new:N \l_booklist_dateb_unknown_bool
\seq_new:N \l_booklist_daterange_seq
% TODO Make this into a prop

\cs_new:Nn \__booklist_populate_datea:N {
	% Pops an number from the left of the sequence \l_booklist_daterange_seq
	% and stores it in the integer variable #1 (setting
	% \l_booklist_datea_approx_bool to true if there is a character 'c' in the
	% sequence item)
	\seq_pop_left:NN \l_booklist_daterange_seq \l_tmpa_tl
	\tl_if_in:NnT \l_tmpa_tl {c} {
		\tl_remove_all:Nn \l_tmpa_tl {c}
		\bool_set_true:N \l_booklist_datea_approx_bool
	}
	\int_set:Nn #1 {\tl_use:N \l_tmpa_tl}
}

\cs_new:Nn \__booklist_populate_dateb:NN {
	% Analogous to \__booklist_populate_datea:N but for dateb.
	% Because the month and year are optional in dateb, this falls back to
	% datea.
	% #1: variable to use for dateb
	% #2: variable to use for datea (fallback)
	\seq_pop_right:NNTF \l_booklist_daterange_seq \l_tmpb_tl
	{
		\tl_if_in:NnTF \l_tmpb_tl {?} {
			\bool_set_true:N \l_booklist_dateb_unknown_bool
			\int_set_eq:NN #1 #2
		}
		{
			\tl_if_in:NnT \l_tmpb_tl {c} {
				\tl_remove_all:Nn \l_tmpb_tl {c}
				\bool_set_true:N \l_booklist_dateb_approx_bool
			}
			\int_set:Nn #1 {\tl_use:N \l_tmpb_tl}
		}
	}
	{
		\int_set_eq:NN #1 #2
	}
}

\cs_new:Nn \__booklist_format_daterange:N {
	% #1: token list variable to interpret as a date range

	\seq_set_split:NnV \l_booklist_daterange_seq {-} #1
	\bool_set_false:N \l_booklist_datea_approx_bool

	\__booklist_populate_datea:N \l_booklist_datea_year_int
	\__booklist_populate_datea:N \l_booklist_datea_month_int
	\__booklist_populate_datea:N \l_booklist_datea_day_int

	\__booklist_populate_dateb:NN
		\l_booklist_dateb_day_int \l_booklist_datea_day_int
	\__booklist_populate_dateb:NN
		\l_booklist_dateb_month_int \l_booklist_datea_month_int
	\__booklist_populate_dateb:NN
		\l_booklist_dateb_year_int \l_booklist_datea_year_int

	\int_compare:nNnTF
	{\l_booklist_datea_year_int} = {\l_booklist_dateb_year_int}
	{
		\bool_if:NT \l_booklist_datea_approx_bool {\textasciitilde{}}
		\DTMenglishordinal{\int_use:N \l_booklist_datea_day_int}
		\DTMenGBdaymonthsep
		\DTMenglishshortmonthname{
			\int_use:N \l_booklist_datea_month_int
		}
		, ~
		\bool_if:NTF \l_booklist_dateb_unknown_bool
		{
			\prop_get:NnNT \g_booklist_config_prop {unknowncolor}
			\l_tmpa_tl {
				\color{\tl_use:N \l_tmpa_tl}
			}
			{???}
		}
		{
			\bool_if:NT \l_booklist_dateb_approx_bool {
				\textasciitilde{}
			}
			\DTMenglishordinal{\int_use:N \l_booklist_dateb_day_int}
			\DTMenGBdaymonthsep
			\DTMenglishshortmonthname{
				\int_use:N \l_booklist_dateb_month_int
			}

			\int_compare:nNnF
			{\l_booklist_dateb_year_int}
			= {\g_booklist_currentyear_int}
			{
				\DTMenGBmonthyearsep
				\int_use:N \l_booklist_dateb_year_int

				\int_compare:nNnT
				{\l_booklist_dateb_year_int}
				> {\g_booklist_currentyear_int}
				{
					\int_gset_eq:NN
					\g_booklist_currentyear_int
					\l_booklist_dateb_year_int
				}
			}
		}
	}
	{
		\bool_if:NT \l_booklist_datea_approx_bool {\textasciitilde{}}
		\DTMDisplaydate
		{\int_use:N \l_booklist_datea_year_int}
		{\int_use:N \l_booklist_datea_month_int}
		{\int_use:N \l_booklist_datea_day_int}
		{-1}
		, ~
		\bool_if:NTF \l_booklist_dateb_unknown_bool
		{
			\prop_get:NnNT \g_booklist_config_prop {unknowncolor}
			\l_tmpa_tl {
				\color{\tl_use:N \l_tmpa_tl}
			}
			{???}
		}
		{
			\bool_if:NT \l_booklist_dateb_approx_bool {
				\textasciitilde{}
			}
			\DTMDisplaydate
			{\int_use:N \l_booklist_dateb_year_int}
			{\int_use:N \l_booklist_dateb_month_int}
			{\int_use:N \l_booklist_dateb_day_int}
			{-1}

			\int_compare:nNnT
			{\l_booklist_dateb_year_int}
			> {\g_booklist_currentyear_int}
			{
				\int_gset_eq:NN
					\g_booklist_currentyear_int
					\l_booklist_dateb_year_int
			}
		}
	}
}

\seq_new:N \l_booklist_dateranges_seq
\cs_new:Nn \booklist_format_date:N {
	% #1: prop with book information
	\prop_if_in:NnTF #1 {date}
		{
			\prop_get:NnN #1 {date} \l_tmpa_tl
			\seq_set_split:NnV \l_booklist_dateranges_seq {;} \l_tmpa_tl
			\bool_until_do:nn {\seq_if_empty_p:N \l_booklist_dateranges_seq} {
				\seq_pop_left:NNT \l_booklist_dateranges_seq \l_tmpa_tl
					{\__booklist_format_daterange:N \l_tmpa_tl}
				\seq_if_empty:NF \l_booklist_dateranges_seq {;~}
			}
		}
		{\multicolumn{1}{c}{(No~Date)}}
}

\NewDocumentCommand \book {m} {
	\prop_clear_new:N \g_booklist_book_prop
	\prop_gset_from_keyval:Nn \g_booklist_book_prop {#1}
	\int_gincr:N \g_booklist_count_int

	\bool_if:NTF \g_booklist_isfirstrow_bool
		{\bool_gset_false:N \g_booklist_isfirstrow_bool}
		{\\\midrule}
	\bool_lazy_or:nnT
		{\prop_if_in_p:Nn \g_booklist_book_prop {heading}}
		{\prop_if_in_p:Nn \g_booklist_book_prop {subheading}}
	{
		\prop_if_in:NnT \g_booklist_book_prop {heading} {
			\prop_if_in:NnT \g_booklist_book_prop {beforeheading} {
				\prop_item:Nn \g_booklist_book_prop {beforeheading}
			}
			\multicolumn{4}{Sc}{
				\Large \prop_item:Nn \g_booklist_book_prop {heading}
			}
		}
		\prop_if_in:NnT \g_booklist_book_prop {subheading} {
			\prop_if_in:NnT \g_booklist_book_prop {heading} {
				\\
			}
			\prop_if_in:NnT \g_booklist_book_prop {beforeheading} {
				\prop_item:Nn \g_booklist_book_prop {beforeheading}
			}
			\multicolumn{4}{c}{
				\prop_item:Nn \g_booklist_book_prop {subheading}
			}
		}
		\\\midrule
	}

	\prop_if_in:NnT \g_booklist_book_prop {beforerow} {
		\prop_item:Nn \g_booklist_book_prop {beforerow}
	}
	\prop_get:NnNT \g_booklist_config_prop {liningnums} \l_tmpa_tl {
		\tl_use:N \l_tmpa_tl
	}
	{\int_use:N \g_booklist_count_int} &
	\booklist_format_title:N \g_booklist_book_prop &
	\booklist_format_author:N \g_booklist_book_prop &
	\booklist_format_date:N \g_booklist_book_prop
}

\title{
	\prop_get:NnNTF \g_booklist_config_prop {title} \l_tmpa_tl
		{\tl_use:N \l_tmpa_tl}
		{2019-20~Book~List}
}
\author{
	\prop_get:NnNT \g_booklist_config_prop {author} \l_tmpa_tl
		{\tl_use:N \l_tmpa_tl}
}
\date{}

\AtBeginDocument{\maketitle}

\endinput
