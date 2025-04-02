# Perl: Payroll System
# 6Diproglang 2084 CS202
# Group Members:
# Alvarez, Rainier
# Morabe, Gabriel
# Nilayan, Marvin
# Palma, Jasmine
# Wylengco, Teyshaun

#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use File::Slurp;

# Define the database file
my $DB_FILE = "database.json";

# Method to create the database file, if it doesn't yet exist
sub init_db {
    unless (-e $DB_FILE) {
        write_file($DB_FILE, encode_json([]));
    }
}

# Method to read the database file
sub read_db {
    my $json_text = read_file($DB_FILE);
    return decode_json($json_text);
}

# Method to write to the database file
sub write_db {
    my ($data) = @_;
    my $json = JSON->new->pretty->encode($data);
    write_file($DB_FILE, $json);
}

# Method to create a new record
sub create_record {
    my ($name, $age, $email, $rate, $hours, $deductions) = @_;
    my $db = read_db();
    my $id = @$db ? $db->[-1]->{id} + 1 : 1;  # Auto-increment ID
    
    my $salary = ($rate * $hours) - $deductions;  # Compute basic salary

    push @$db, { 
        id => $id, 
        name => $name, 
        age => $age, 
        email => $email, 
        rate => $rate, 
        hours => $hours, 
        deductions => $deductions, 
        salary => $salary 
    };

    write_db($db);
    print "Record added: ID=$id, Name=$name, Salary=\$$salary\n";
}

# Method to read all records
sub read_records {
    my $db = read_db();
    foreach my $rec (@$db) {
        print "ID: $rec->{id}, Name: $rec->{name}, Age: $rec->{age}, Email: $rec->{email}, ";
        print "Rate: $rec->{rate}, Hours: $rec->{hours}, Deductions: $rec->{deductions}, Salary: \$$rec->{salary}\n";
    }
}

# Method to update a record via id
sub update_record {
    my ($id, $name, $age, $email, $rate, $hours, $deductions) = @_;
    my $db = read_db();

    foreach my $rec (@$db) {
        if ($rec->{id} == $id) {
            $rec->{name}  = $name  if defined $name;
            $rec->{age}   = $age   if defined $age;
            $rec->{email} = $email if defined $email;
            $rec->{rate}  = $rate  if defined $rate;
            $rec->{hours} = $hours if defined $hours;
            $rec->{deductions} = $deductions if defined $deductions;
            
            # Recalculate salary
            $rec->{salary} = ($rec->{rate} * $rec->{hours}) - $rec->{deductions};
            
            write_db($db);
            print "Record ID $id updated.\n";
            return;
        }
    }
    print "Record ID $id not found.\n";
}

# Method to delete a record via id
sub delete_record {
    my ($id) = @_;
    my $db = read_db();
    my @filtered_db = grep { $_->{id} != $id } @$db;
    
    if (@$db == @filtered_db) {
        print "Record ID $id not found.\n";
    } else {
        write_db(\@filtered_db);
        print "Record ID $id deleted.\n";
    }
}

# Method to Search records by name
sub search_records {
    my ($name) = @_;
    my $db = read_db();
    my @results = grep { $_->{name} =~ /\Q$name\E/i } @$db;

    if (@results) {
        foreach my $rec (@results) {
            print "ID: $rec->{id}, Name: $rec->{name}, Age: $rec->{age}, Email: $rec->{email}, ";
            print "Rate: $rec->{rate}, Hours: $rec->{hours}, Deductions: $rec->{deductions}, Salary: \$$rec->{salary}\n";
        }
    } else {
        print "No records found for name '$name'.\n";
    }
}

# Method to calculate and print total salary of all employees
sub total_salaries {
    my $db = read_db();
    my $total_salary = 0;

    foreach my $rec (@$db) {
        $total_salary += $rec->{salary};
    }

    print "Total Salary of all employees: \$$total_salary\n";
}

# Method for the system menu
sub menu {
    init_db();
    while (1) {
        print "\n[Database Management System]\n";
        print "1. Create Record\n";
        print "2. Read Records\n";
        print "3. Update Record\n";
        print "4. Delete Record\n";
        print "5. Search Records\n";
        print "6. Total Salaries\n";
        print "7. Exit\n";
        print "Choose an option: ";
        my $choice = <STDIN>;
        chomp($choice);

        if ($choice == 1) {
            print "Enter Name: "; my $name = <STDIN>; chomp($name);
            print "Enter Age: "; my $age = <STDIN>; chomp($age);
            print "Enter Email: "; my $email = <STDIN>; chomp($email);
            print "Enter Hourly Rate: "; my $rate = <STDIN>; chomp($rate);
            print "Enter Hours Worked: "; my $hours = <STDIN>; chomp($hours);
            print "Enter Deductions: "; my $deductions = <STDIN>; chomp($deductions);
            create_record($name, $age, $email, $rate, $hours, $deductions);
        } elsif ($choice == 2) {
            read_records();
        } elsif ($choice == 3) {
            print "Enter ID to update: "; my $id = <STDIN>; chomp($id);
            print "Enter New Name (or press Enter to skip): "; my $name = <STDIN>; chomp($name);
            print "Enter New Age (or press Enter to skip): "; my $age = <STDIN>; chomp($age);
            print "Enter New Email (or press Enter to skip): "; my $email = <STDIN>; chomp($email);
            print "Enter New Hourly Rate (or press Enter to skip): "; my $rate = <STDIN>; chomp($rate);
            print "Enter New Hours Worked (or press Enter to skip): "; my $hours = <STDIN>; chomp($hours);
            print "Enter New Deductions (or press Enter to skip): "; my $deductions = <STDIN>; chomp($deductions);
            update_record($id, $name || undef, $age || undef, $email || undef, $rate || undef, $hours || undef, $deductions || undef);
        } elsif ($choice == 4) {
            print "Enter ID to delete: "; my $id = <STDIN>; chomp($id);
            delete_record($id);
        } elsif ($choice == 5) {
            print "Enter Name to search: "; my $name = <STDIN>; chomp($name);
            search_records($name);
        } elsif ($choice == 6) {
            total_salaries();
        } elsif ($choice == 7) {
            print "Exiting...\n";
            last;
        } else {
            print "Invalid choice, try again.\n";
        }
    }
}

# Run menu
menu();