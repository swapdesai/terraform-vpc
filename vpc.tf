provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "ap-southeast-2"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"

	tags {
    Name = "tf_vpc"
  }
}

resource "aws_internet_gateway" "tf_internet_gateway" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	tags {
    Name = "tf_internet_gateway"
  }
}

# Public subnets
resource "aws_subnet" "ap_southeast_2a_public" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.0.0/24"
	availability_zone = "ap-southeast-2a"

	tags {
    Name = "ap_southeast_2a_public"
  }
}

resource "aws_subnet" "ap_southeast_2b_public" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.2.0/24"
	availability_zone = "ap-southeast-2b"

	tags {
    Name = "ap_southeast_2b_public"
  }
}

# Private subsets
resource "aws_subnet" "ap_southeast_2a_private" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.1.0/24"
	availability_zone = "ap-southeast-2a"

	tags {
    Name = "ap_southeast_2a_private"
  }
}

resource "aws_subnet" "ap_southeast_2b_private" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	cidr_block = "10.0.3.0/24"
	availability_zone = "ap-southeast-2b"

	tags {
    Name = "ap_southeast_2b_private"
  }
}

# Routing table for public subnets
resource "aws_route_table" "ap_southeast_2_public" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.tf_internet_gateway.id}"
	}

	tags {
    Name = "ap_southeast_2_public"
  }
}

resource "aws_route_table_association" "ap_southeast_2a_public" {
	subnet_id = "${aws_subnet.ap_southeast_2a_public.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_public.id}"
}

resource "aws_route_table_association" "ap_southeast_2b_public" {
	subnet_id = "${aws_subnet.ap_southeast_2b_public.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_public.id}"
}

# Routing table for private subnets
resource "aws_route_table" "ap_southeast_2_private" {
	vpc_id = "${aws_vpc.tf_vpc.id}"

	tags {
    Name = "ap_southeast_2_private"
  }
}

resource "aws_route_table_association" "ap_southeast_2a_private" {
	subnet_id = "${aws_subnet.ap_southeast_2a_private.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_private.id}"
}

resource "aws_route_table_association" "ap_southeast_2b_private" {
	subnet_id = "${aws_subnet.ap_southeast_2b_private.id}"
	route_table_id = "${aws_route_table.ap_southeast_2_private.id}"
}
