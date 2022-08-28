#
# Authentic Theme (https://github.com/authentic-theme/authentic-theme)
# Copyright Ilia Rostovtsev <ilia@virtualmin.com>
# Licensed under MIT (https://github.com/authentic-theme/authentic-theme/blob/master/LICENSE)
#
use strict;

our (%in,
     %text,
     %module_text_full,
     %theme_text,
     %theme_config,
     %gconfig,
     $current_lang_info,
     $root_directory,
     $config_directory,
     $current_theme,
     $theme_webprefix,
     $module_name,
     $remote_user,
     $get_user_level);

=head2 settings(file, [grep_pattern])
Parses given JavaScript filename to a hash reference

=cut

sub settings
{
    my ($f, $e) = @_;
    my %c;
    if (-r $f) {
        my $k = read_file_contents($f);
        my %k = $k =~ /\s*(.*?)\s*=\s*(.*)\s*/g;
        delete @k{ grep(!/^$e/, keys %k) }
          if ($e);
        foreach my $s (keys %k) {
            $k{$s} =~ s/^[^']*\K'|'(?=[^']*$)|[;,](?=[^;,]*$)//g;
            $k{$s} =~ s/\\'/'/g;
            $c{$s} .= $k{$s};
        }
        return %c;
    } else {
        return %c;
    }
}

sub ui_button_group_local
{
    my ($buttons, $extra_class) = @_;
    my $rv;
    $rv = "<div class=\"btn-group $extra_class\">$buttons</div>";
    return $rv;
}

sub ui_element
{
    my ($e, $c) = @_;

    # Allowed elements to use 'type' attr
    if ($e =~ /^(a|button|embed|input|link|menu|object|script|source|style)$/) {

        # Set default `type` for common elements
        if ($e eq 'input') {
            $c->{'type'} = "text" if (!$c->{'type'});
        } elsif ($e eq 'button') {
            $c->{'type'} = "button" if (!$c->{'type'});
        }
        $c->{'type'} = " type=\"@{[quote_escape($c->{'type'})]}\"" if ($c->{'type'});
    } else {
        delete $c->{'type'};
    }

    # Allowed elements to use 'name' attr
    if ($e =~ /^(button|fieldset|form|iframe|input|map|meta|object|output|param|select|textarea)$/) {
        $c->{'name'} = " name=\"@{[quote_escape($c->{'name'})]}\"" if ($c->{'name'});
    } else {
        delete $c->{'name'};
    }

    # Allowed elements to use 'value' attr
    if ($e =~ /^(button|input|meter|li|option|progress|param)$/) {
        $c->{'value'} = " value=\"@{[quote_escape($c->{'value'})]}\"" if ($c->{'value'});
    } else {
        delete $c->{'value'};
    }

    # Trigger `autofocus` or remove it
    if ($e =~ /^(button|input|select|textarea)$/) {
        if ($c->{'autofocus'} =~ /^(false|0)$/) {
            delete $c->{'autofocus'};
        }

        # If element is empty trigger autofocus
        elsif ($e =~ /input|textarea/ && !$c->{'value'}) {
            $c->{'autofocus'} = " autofocus";
        }
    }

    # Set default `class` for common elements
    if (!$c->{'class'}) {
        my $c_;
        if ($e eq 'input') {
            $c_ = "form-control";
            if ($c->{'type'} =~ /password/) {
                $c_ .= " ui_password";
            } else {
                $c_ .= " ui_textbox";
            }
        } elsif ($e eq 'textarea') {
            $c_ = "form-control ui_textarea";
        }
        $c->{'class'} = " class=\"$c_\"";
    } else {
        $c->{'class'} = " class=\"@{[quote_escape($c->{'class'})]}\"";
    }

    # Collect all other independent attributes
    my $attrs;
    foreach my $attr (keys %{$c}) {
        if ($attr ne "class" &&
            $attr ne "value" &&
            $attr ne "name"  &&
            $attr ne "type")
        {

            # Parse and add data attributes passed as reference
            if ($attr eq "data") {
                if (ref($c->{$attr})) {
                    foreach my $dattr (keys %{ $c->{$attr} }) {
                        $attrs .= " data-$dattr=\"@{[quote_escape($c->{$attr}->{$dattr})]}\"";
                    }
                }

                # Add all other attributes to the tag
            } else {
                $attrs .= " $attr=\"@{[quote_escape($c->{$attr})]}\"";
            }
        }
    }

    # Check if a tag must be closed
    my $e_c;
    if ($e !~ /^(area|base|br|hr|input|link|meta|param|source|circle|track|wbr)$/) {
        $e_c = "</$e>";
    }
    return "<$e$c->{'type'}$c->{'name'}$c->{'value'}$c->{'class'}$attrs>@{[html_escape($c->{'_'})]}$e_c\n";
}

sub ui_input
{
    my ($c, $v, $s, $d, $m, $t) = @_;

    # If old type input used, support it as well
    if (!ref($c)) {
        $c = { 'name'  => $c,
               'value' => $v,
               'size'  => $s };
        $c->{'disabled'}  = "true" if ($d);
        $c->{'maxlength'} = $m     if ($m);
        if ($t) {
            my @t = split(/\s+/, $t);
            foreach my $t (@t) {
                my ($t, $v) = ($t =~ /(.*?)=(.*)/);
                $v =~ s/^("|')|("|')$//g;
                $c->{$t} = "@{[quote_escape($v)]}";
            }
        }
    }
    return ui_element('input', $c);
}

sub ui_span_local
{
    my ($data, $extra_class) = @_;
    my $rv;
    if ($extra_class) {
        $extra_class = " class=\"$extra_class\"";
    }
    $rv = "<span$extra_class>$data</span>";
    return $rv;
}

sub ui_dropdown_local
{

    my ($elements, $dconfig) = @_;
    my $dconf_toggle          = $dconfig->{'tooltip'}         || 'tooltip';
    my $dconf_container       = $dconfig->{'container'}       || 'body';
    my $dconf_title           = $dconfig->{'title'}           || undef;
    my $dconf_container_class = $dconfig->{'container-class'} || undef;
    my $dconf_button_class    = $dconfig->{'button-class'}    || 'btn-default';
    my $dconf_button_icon     = $dconfig->{'icon'} ? "<span class=\"$dconfig->{'icon'}\"></span>"             : undef;
    my $dconf_button_text     = $dconfig->{'text'} ? "&nbsp;<span data-entry>$dconfig->{'text'}&nbsp;</span>" : undef;
    my $dconf_ul_class        = $dconfig->{'ul-class'} || undef;
    my $dconf_li_class        = $dconfig->{'li-class'} || undef;
    my $lis;

    foreach my $e (@{$elements}) {
        $lis .= "<li class=\"$dconf_li_class\">$e</li>\n";
    }
    return
"<div data-toggle=\"$dconf_toggle\" data-container=\"$dconf_container\" data-title=\"$dconf_title\" class=\"btn-group $dconf_container_class\">
    <button aria-label=\"$dconf_title\" data-toggle=\"dropdown\" class=\"btn dropdown-toggle $dconf_button_class\" aria-expanded=\"false\">
        $dconf_button_icon$dconf_button_text
    </button>                                    
    <ul class=\"dropdown-menu $dconf_ul_class\" role=\"menu\">
        $lis
    </ul>
</div>";
}

sub theme_ui_checkbox_local
{
    my ($name, $value, $label, $sel, $tags, $dis, $cls) = @_;
    my $after;
    my $rand = int rand(1e4);
    if ($label =~ /^([^<]*)(<[\000-\377]*)$/) {
        $label = $1;
        $after = $2;
    }
    $label = trim($label);
    my $bl = string_ends_with($label, '<br>') ? ' ds-bl-fs' : undef;
    return "<span class=\"awcheckbox awobject$bl$cls\"><input class=\"iawobject\" type=\"checkbox\" " .
      "name=\"" . &quote_escape($name) . "\" " . "value=\"" . &quote_escape($value) . "\" " . ($sel ? " checked" : "") .
      ($dis  ? " disabled=true" : "") . " id=\"" . &quote_escape("${name}_${value}_${rand}") . "\"" .
      ($tags ? " " . $tags      : "") . "> " . '<label class="lawobject" for="' . &quote_escape("${name}_${value}_${rand}") .
      '">' . (length $label ? "&nbsp;&nbsp;<span data-label-text>$label</span>&nbsp;" : '&nbsp;&nbsp;') .
      '</label></span>' . $after;
}

sub theme_make_date_local
{
    if (
        (
         (get_env('script_name') =~ /disable_domain/ ||
          $main::webmin_script_type ne 'web' ||
          ($main::header_content_type ne "text/html" &&
              $main::header_content_type ne "application/json")
         ) &&
         !$main::theme_allow_make_date
        ) ||
        $theme_config{'settings_theme_make_date'} eq 'false')
    {
        $main::theme_prevent_make_date = 1;
        return &make_date(@_);
    }
    my ($s, $o, $f) = @_;
    my $t = "x-md";
    my $d = "<$t-d>$s";
    ($d .= (string_starts_with($f, 'yyyy') ? ";2" : (string_contains($f, 'mon') ? ";1" : ($f == -1 ? ";-1" : ";0"))) .
     "</$t-d>");
    (!$o && ($d .= " <$t-t>$s</$t-t>"));
    return $d;
}

sub theme_nice_size_local
{
    my ($bytes, $minimal, $decimal) = @_;

    my ($decimal_units, $binary_units) = (1000, 1024);
    my $bytes_initial = $bytes;
    my $unit          = $decimal ? $decimal_units : $binary_units;

    my $label = sub {
        my ($item) = @_;
        my $text   = 'theme_xhred_nice_size_';
        my $unit   = ($unit > $decimal_units ? 'I' : undef);
        my @labels = ($theme_text{"${text}b"},
                      $theme_text{"${text}k${unit}B"},
                      $theme_text{"${text}M${unit}B"},
                      $theme_text{"${text}G${unit}B"},
                      $theme_text{"${text}T${unit}B"},
                      $theme_text{"${text}P${unit}B"});
        return $labels[$item - 1];
    };
    my $allowed = sub {
        my ($item) = @_;
        return $minimal >= $unit && $minimal >= ($unit**$item);
    };

    my $do = sub {
        my ($bytes) = @_;
        return abs($bytes) >= $unit;
    };

    my $item = 1;
    if (&$do($bytes)) {
        do {
            $bytes /= $unit;
            ++$item;
        } while ((&$do($bytes) || &$allowed($item)) && $item <= 5);
    } elsif (&$allowed($item)) {
        $item  = int(log($minimal) / log($unit)) + 1;
        $bytes = $item == 2 ? $bytes / (defined($unit) ? $unit : $item) : 0;
    }

    my $factor    = 10**2;
    my $formatted = int($bytes * $factor) / $factor;

    if ($minimal == -1) {
        return $formatted . " " . &$label($item);
    }
    return '<span data-filesize-bytes="' . $bytes_initial . '">' . ($formatted . " " . &$label($item)) . '</span>';
}

sub nice_number
{
    my ($number, $delimiter) = @_;
    $delimiter = " " if (!$delimiter);
    $number =~ s/(\d)(?=(\d{3})+(\D|$))/$1$delimiter/g;
    return $number;
}

sub get_time_offset
{
    my $offset = backquote_command('date +"%z"');
    $offset =~ s/\n//;
    return $offset;
}

sub get_theme_language
{
    my %s;
    foreach my $key (keys %theme_text) {
        if ($key !~ /_xhred_/ &&
            $key !~ /body_/  &&
            $key !~ /right_/ &&
            $key !~ /_level_navigation/)
        {
            next;
        }
        $s{$key} = $theme_text{$key};
    }

    # Pass additional language strings on initial load
    my @mod_extra_lang = ("virtual-server");
    foreach my $mod (@mod_extra_lang) {
        if (foreign_available($mod)) {
            $mod =~ s/\-/_/g;
            my @extras = ('scripts_desc');
            foreach my $key (@extras) {
                $s{"${mod}_${key}"} = $theme_text{$key} || "";
            }
        }
    }
    return convert_to_json(\%s);

}

sub get_user_allowed_gpg_keys
{
    my ($switch_to_user, $list_avoided_system_keys, $self) = @_;
    my %keys_;

    # Also get the keys for the root user, when operating on virtual server
    # so the master admin will see all root keys, plus the keys from given
    # virtual server
    my ($user_level) = get_user_level();
    if (!$user_level && !$self) {
        my ($root_keys) = get_user_allowed_gpg_keys($remote_user, $list_avoided_system_keys, 'self');
        %keys_ = %{$root_keys};
    }

    # Switch to remove user first
    my ($switched_user) = switch_to_given_unix_user($switch_to_user);

    # GNUPG lib target
    # For Usermin `gnupg` for Webmin `webmin`
    my $target = foreign_exists('gnupg') ? 'gnupg' : 'webmin';

    # As we call it not from the module set it manually
    # to bypass init_config() call leading to an error
    $module_name = $target;

    my $gpglib = $root_directory . "/$target/gnupg-lib.pl";
    if (-r $gpglib) {
        do($gpglib);
        my %gpgconfig = foreign_config($target);
        my $gpgpath   = $gpgconfig{'gpg'} || "gpg";

        # If this is Jamie's, Joe's or Ilia's machine, where also a private key
        # may be available, it would be possible to list the keys on dropdown too,
        # as those keys are distributed and should never be displayed to the users.
        # If one of us needs the keys to be displayed on the dropdown we need to hold
        # Alt key before clicking Encrypt entry on File Manager context menu
        my @keys_avoided = ('11F63C51', 'F9232D77', 'D9C821AB');
        my @keys         = list_keys_sorted();
        my @keys_secret  = sort {lc($a->{'name'}->[0]) cmp lc($b->{'name'}->[0])} list_secret_keys();

        foreach my $k (@keys) {
            my $key   = substr($k->{'key'}, -8, 8);
            my $suser = $switched_user || $remote_user;
            my $name  = $k->{'name'}->[0];
            $name =~ s/\(.*?\)//gs;
            if ($list_avoided_system_keys || (!$list_avoided_system_keys && !grep(/^$key$/, @keys_avoided))) {
                $keys_{ $k->{'key'} } =
                  trim($name) . " ($k->{'email'}->[0] [$suser] [$key/$k->{'size'}, $k->{'date'}])";
            }
        }
        return (\%keys_, $gpgpath);
    }
}

sub get_user_level
{
    my ($level, $has_virtualmin, $has_cloudmin);
    $has_cloudmin   = &foreign_available("server-manager");
    $has_virtualmin = &foreign_available("virtual-server");
    if ($has_cloudmin) {
        &foreign_require("server-manager", "server-manager-lib.pl");
    }
    if ($has_virtualmin) {
        &foreign_require("virtual-server", "virtual-server-lib.pl");
    }
    if ($has_cloudmin) {
        no warnings 'once';
        $level = $server_manager::access{'owner'} ? 4 : 0;
    } elsif ($has_virtualmin) {
        $level =
          &virtual_server::master_admin()   ? 0 :
          &virtual_server::reseller_admin() ? 1 :
          2;
    } elsif (&get_product_name() eq "usermin") {
        $level = 3;
    } else {
        $level = 0;
    }
    return ($level, $has_virtualmin, $has_cloudmin);
}

sub switch_to_given_unix_user
{
    return if (!supports_users());

    my ($username)   = @_;
    my ($user_level) = get_user_level();

    my $username_params = $in{'username'} || $in{'switch_to_username'};

    # Fix to emphasise that only root user can supply a username as param
    $username ||= $username_params
      if (!$user_level);

    # If username isn't set set it to remote user
    $username ||= $remote_user
      if ($user_level);

    if ($username) {
        my @uinfo = getpwnam($username);
        if (@uinfo) {
            switch_to_unix_user(\@uinfo)
              if ($username ne $remote_user);
            $ENV{'USER'} = $ENV{'LOGNAME'} = $username;
            $ENV{'HOME'} = $uinfo[7];
            return ($username, $uinfo[7]);
        }
    }
}

sub theme_get_webprefix_local
{
    my ($array)               = @_;
    my $webprefix             = $gconfig{'webprefix'};
    my $parent_proxy_detected = 0;
    my $parent_proxy          = $ENV{'HTTP_COMPLETE_WEBMIN_PATH'} || $ENV{'HTTP_WEBMIN_PATH'};
    if ($parent_proxy) {
        my ($parent_proxy_link)   = $parent_proxy      =~ /(\S*?\/link\.cgi\/[\d]{8,16})/;
        my ($parent_proxy_prefix) = $parent_proxy_link =~ /:\d+(\S*?\/link\.cgi\/\S*?\d+)/;
        if ($parent_proxy_prefix) {
            $webprefix             = $parent_proxy_prefix;
            $parent_proxy_detected = 1;
        }
    }
    return $array ? ($webprefix, $parent_proxy_detected) : $webprefix;
}

sub get_text_ltr
{
    if ($current_lang_info && $current_lang_info->{'rtl'} eq "1") {
        return 0;
    } else {
        return 1;
    }
}

sub reverse_string
{
    my ($str, $delimiter) = @_;
    my @strings = reverse(split(/\Q$delimiter\E/, $str));
    return join(" " . $delimiter . " ", @strings);
}

sub ltrim
{
    my $s = shift;
    $s =~ s/^\s+//;
    return $s;
}

sub rtrim
{
    my $s = shift;
    $s =~ s/\s+$//;
    return $s;
}

sub trim
{
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

sub trim_lines
{
    my $s = shift;
    $s =~ s/[\n\r]//g;
    return $s;
}

sub replace
{
    my ($from, $to, $string) = @_;
    $string =~ s/\Q$from\E/$to/ig;

    return $string;
}

sub replace_meta
{
    my ($string) = @_;

    my $hostname   = &get_display_hostname();
    my $version    = &get_webmin_version();
    my $os_type    = $gconfig{'real_os_type'}    || $gconfig{'os_type'};
    my $os_version = $gconfig{'real_os_version'} || $gconfig{'os_version'};
    $string =~ s/%HOSTNAME%/$hostname/g;
    $string =~ s/%VERSION%/$version/g;
    $string =~ s/%USER%/$remote_user/g;
    $string =~ s/%OS%/$os_type $os_version/g;

    return $string;
}

sub product_version_update_remote
{
    my ($latest_known_versions_remote, $latest_known_versions_remote_error, %versions_available);
    my $software_latest_cache       = theme_cached('software+latest');
    my $software_latest_cache_extra = sub {
        my ($software_latest_cache_original) = @_;
        my $software_latest_cache_extra_csf  = theme_cached('version-csf-stable');
        my $software_latest_cache_merged     = {};

        if ($software_latest_cache_original && $software_latest_cache_extra_csf) {
            $software_latest_cache_extra_csf = { 'csf' => $software_latest_cache_extra_csf };
            $software_latest_cache_merged    = { %{$software_latest_cache_original}, %{$software_latest_cache_extra_csf} };
        } elsif (!$software_latest_cache_original && $software_latest_cache_extra_csf) {
            $software_latest_cache_merged = { 'csf' => $software_latest_cache_extra_csf };
        } elsif ($software_latest_cache_original && !$software_latest_cache_extra_csf) {
            $software_latest_cache_merged = $software_latest_cache_original;
        }
        return $software_latest_cache_merged;
    };

    if ($software_latest_cache) {
        return &$software_latest_cache_extra($software_latest_cache);
    } else {
        my $packages_updates_mod = 'package-updates';
        my $packages_updates     = &foreign_available($packages_updates_mod);
        return { 'no-cache' => 1 }
          if (!post_has('xhr-') ||
              !$packages_updates);
        if ($packages_updates) {
            &foreign_require($packages_updates_mod);
            my @packages_updates_current = &package_updates::list_for_mode('updates', 0);
            if (@packages_updates_current) {
                foreach my $package_current (@packages_updates_current) {
                    my ($package, $version) = ($package_current->{'name'}, $package_current->{'version'});
                    if ($package &&
                        $version &&
                        $package =~ /^(wbm|wbt|ust|webmin|usermin)/)
                    {
                        $package =~ s/^(wbm|wbt|ust|webmin|usermin)\-//;
                        $versions_available{$package} = $version;
                    }

                }
            }
        }
        theme_cached('software+latest', \%versions_available);
        return &$software_latest_cache_extra(\%versions_available);
    }

}

sub product_version_update
{
    my ($product_local_version, $product_local_name) = @_;
    return $product_local_version
      if ($theme_config{'settings_check_remote_updates'} eq 'false');
    my $software_versions_remote = product_version_update_remote();
    return $product_local_version
      if ($software_versions_remote->{'no-cache'});

    # Remote versions
    my $product_remote_version =
      $product_local_name eq "w" ? ["Webmin",                           $software_versions_remote->{'webmin'}] :
      $product_local_name eq "u" ? ["Usermin",                          $software_versions_remote->{'usermin'}] :
      $product_local_name eq "v" ? ["Virtualmin",                       $software_versions_remote->{'virtual-server'}] :
      $product_local_name eq "c" ? ["Cloudmin",                         $software_versions_remote->{'server-manager'}] :
      $product_local_name eq "f" ? ["ConfigServer Security & Firewall", $software_versions_remote->{'csf'}] :
      "";

    # Compare versions
    if (
        ($product_local_name eq "w" &&
         &compare_version_numbers($product_local_version, $software_versions_remote->{'webmin'}) < 0
        ) ||
        ($product_local_name eq "u" &&
            &compare_version_numbers($product_local_version, $software_versions_remote->{'usermin'}) < 0) ||
        ($product_local_name eq "v" &&
            &compare_version_numbers($product_local_version, $software_versions_remote->{'virtual-server'}) < 0) ||
        ($product_local_name eq "c" &&
            &compare_version_numbers($product_local_version, $software_versions_remote->{'server-manager'}) < 0) ||
        ($product_local_name eq "f" &&
            &compare_version_numbers($product_local_version, $software_versions_remote->{'csf'}) < 0))
    {
        if (&foreign_available("virtual-server")) {
            return '<a href="https://forum.virtualmin.com/search?q=' .
              $product_remote_version->[0] . '%20in%3Atitle%20%23news%20order%3Alatest" target="_blank">' .
              '<span data-toggle="tooltip" data-placement="auto top" data-title="' .
              theme_text('theme_xhred_global_outdated_desc', $product_remote_version->[0], $product_remote_version->[1]) .
              '" class="bg-danger text-danger pd-lf-2 pd-rt-2 br-2">' . $product_local_version . '</span></a>';
        } else {
            return '<span data-toggle="tooltip" data-placement="auto top" data-title="' .
              theme_text('theme_xhred_global_outdated_desc2', $product_remote_version->[0], $product_remote_version->[1]) .
              '" class="bg-danger text-danger pd-lf-2 pd-rt-2 br-2">' . $product_local_version . '</span>';
        }
    } else {
        return $product_local_version;
    }
}

sub string_contains
{
    return (index($_[0], $_[1]) != -1);
}

sub string_starts_with
{
    return substr($_[0], 0, length($_[1])) eq $_[1];
}

sub string_ends_with
{
    my $length = length($_[1]);
    return substr($_[0], -$length, $length) eq $_[1];
}

sub array_flatten
{
    return map {ref eq 'ARRAY' ? @$_ : $_} @_;
}

sub array_contains
{
    my ($array_reference, $search, $loose) = @_;
    return (!$loose ? (grep {$_ eq $search} @$array_reference) : (grep {index($_, $search) != -1} @$array_reference));
}

sub array_unique
{
    my @unique;
    my %seen;

    foreach my $value (@_) {
        if (!$seen{$value}++) {
            $value =~ tr/\r\n//d;
            push @unique, $value;
        }
    }
    return @unique;
}

sub get_before_delimiter
{
    my ($v, $d) = @_;

    $v =~ /^(.*)\Q$d\E/;
    return ($1 ? $1 : $v);
}

sub get_chooser_button_template
{
    my ($onclick, $icon) = @_;
    return
"<button class='btn btn-default chooser_button' type=button onClick='ifield = form.$_[0]; chooser = window.open(\"$theme_webprefix/$onclick, \"chooser\"); chooser.ifield = ifield; window.ifield = ifield'>
  <i class=\"fa $icon vertical-align-middle\"></i>
 </button>\n";
}

sub directory_empty
{
    if (-e $_[0] && -d $_[0]) {
        opendir my $dir, $_[0] or die $!;
        if (grep !/^\.\.?$/, readdir $dir) {
            return 0;
        } else {
            return 1;
        }
    }
    return -1;
}

sub hash_to_query
{
    my ($c, %h) = @_;
    return $c . join(q{&}, map {qq{$_=@{[urlize($h{$_})]}}} keys %h);
}

sub head
{
    print "x-no-links: 1\n";
    print "Content-type: text/html\n\n";
}

sub module_text_full
{
    if (!%module_text_full) {
        %module_text_full = load_language(get_module_name());
    }
    return %module_text_full;
}

sub strip_html
{
    my ($string) = @_;
    $string =~ s|<.+?>||g;
    return $string;
}

sub format_document_title
{
    my ($title_initial) = $_[0] =~ /(?|.*:\s+(.*)|(.*))/;
    my ($product, $os_type) = $title_initial =~ /(?|(.*\d+).*(\(.*)|(.*\d+))/;
    $os_type = undef if (length($os_type) < 4);
    my $title = ($os_type ? "$product $os_type" : $product);
    $title =~ s/\R//g;
    return $title;
}

sub current_kill_previous
{
    my ($keep) = @_;
    my $pid = current_running(1);
    if ($pid) {
        kill(9, $pid);
    }
    current_to_pid($keep);
}

sub current_to_filename
{
    my ($filename) = @_;
    my $salt       = substr(encode_base64($main::session_id), 0, 6);
    my $user       = $remote_user;

    $filename =~ s/(?|([\w-]+$)|([\w-]+)\.)//;
    $filename = $1;
    $filename =~ tr/A-Za-z0-9//cd;
    $user     =~ tr/A-Za-z0-9//cd;
    $salt     =~ tr/A-Za-z0-9//cd;
    return '.theme_' . $salt . '_' . get_product_name() . '_' . $user . '_' . "$filename.pid";
}

sub current_running
{
    my ($clean) = @_;
    my %pid;
    my $filename = tempname(current_to_filename($0));
    read_file($filename, \%pid);
    $clean && unlink_file($filename);
    return $pid{'pid'} || 0;
}

sub current_to_pid
{
    my ($keep) = @_;
    my $script = current_to_filename($0);

    my $tmp_file = ($keep ? tempname($script) : transname($script));
    my %pid      = (pid => $$);
    write_file($tmp_file, \%pid);
}

sub network_stats
{
    # Get network data from all interfaces
    my ($type) = @_;
    my $file = "/proc/net/dev";
    return () unless -r $file;
    open(my $dev, $file);
    my (@titles, %result);
    while (my $line = <$dev>) {
        chomp($line);
        if ($line =~ /^.{6}\|([^\\]+)\|([^\\]+)$/) {
            my ($rec, $trans) = ($1, $2);
            @titles = ((map {"r$_"} split(/\s+/, $rec)), (map {"t$_"} split(/\s+/, $trans)));
        } elsif ($line =~ /^\s*([^:]+):\s*(.*)$/) {
            my ($id, @data) = ($1, split(/\s+/, $2));
            $result{$id} = { map {$titles[$_] => $data[$_];} (0 .. $#titles) };
        }
    }
    close($dev);

    # Return current network I/O
    if ($type eq 'io') {
        my ($rbytes, $tbytes, $rbytes2, $tbytes2) = (0, 0, 0, 0);
        my @rs;
        my $results = \%result;

        # Parse current data
        foreach (%$results) {
            $rbytes += $results->{$_}->{'rbytes'};
            $tbytes += $results->{$_}->{'tbytes'};
        }

        # Wait for one second and fetch data over again
        sleep 1, $results = network_stats();

        # Parse data after dalay
        foreach (%$results) {
            $rbytes2 += $results->{$_}->{'rbytes'};
            $tbytes2 += $results->{$_}->{'tbytes'};
        }

        # Return current network I/O
        $rbytes = int($rbytes2 - $rbytes);
        $tbytes = int($tbytes2 - $tbytes);

        @rs = ($rbytes, $tbytes);
        return serialise_variable(\@rs);
    }
    return \%result;
}

sub acl_system_status
{
    my ($show) = @_;
    my %access = get_module_acl($remote_user, 'system-status');
    $access{'show'} ||= "";
    if ($access{'show'} eq '*') {
        return 1;
    } else {
        return indexof($show, split(/\s+/, $access{'show'})) >= 0;
    }
}

sub get_default_module
{
    my $mod_def = $theme_config{'settings_webmin_default_module'};
    if (!foreign_available($mod_def)) {
        $mod_def = $gconfig{'gotomodule'};
        if (!foreign_available($mod_def)) {
            $mod_def = undef;
        }
    }
    if ($mod_def &&
        -r "$root_directory/$mod_def/index.cgi")
    {
        return $mod_def;
    }
    return undef;
}

# If "WebminCore" basic functions are not
# reachable throw UI warning to restart
# Webmin manually. Inner ref.: CXX1010000
sub init_prefail
{
    if (
        # Affects upgrades before 1.974
        !defined(&get_buffer_size) ||

        # Affects upgrades before 1.982
        !defined(&get_webprefix) ||

        # Affects upgrades from before 1.990
        !defined(&getvar) ||
        !defined(&setvar) ||

        # Affects upgrades from before 1.995
        !defined(&webmin_user_can_rpc) ||
        !defined(&webmin_user_is_admin) ||

        # Affects upgrades from before 2.000
        !defined(&get_webmin_full_version))
    {
        load_theme_library();
        do("$root_directory/web-lib-funcs.pl");
        setvar('needs-restart', has_command('systemctl') || $config_directory)
            if (defined(&setvar));
    }
}

sub post_has
{
    my ($key) = @_;
    if (%in) {
        if (grep {$_ =~ /\Q$key\E/} keys %in) {
            return 1;
        }
    }
    return 0;
}

1;
