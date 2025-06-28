resource "aws_vpc" "docuflow-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "DocuFlowVPC"
        Project = "DocuFlow"

    }
}

resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.docuflow-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false
    tags = {
        Name = "PrivateSubnet1"
        Project = "DocuFlow"
    }
}

resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.docuflow-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = false
    tags = {
        Name = "privateSubnet2"
        Project = "DocuFlow"
    }
}

resource "aws_security_group" "lambda-sg" {
    vpc_id = aws_vpc.docuflow-vpc.id
    name = "DocuFlowLambdaSG"
    description = "Security group for Lambda functions in DocuFlow VPC"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Project = "DocuFlow"
    }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.docuflow-vpc.id

  tags = {
    Name    = "DocuFlowPrivateRouteTable"
    Project = "DocuFlow"
  }
}

resource "aws_route_table_association" "private_rt_a" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_b" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id             = aws_vpc.docuflow-vpc.id
  service_name       = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = [aws_route_table.private_rt.id]

  tags = {
    Name    = "DynamoDBEndpoint"
    Project = "DocuFlow"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id             = aws_vpc.docuflow-vpc.id
  service_name       = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = [aws_route_table.private_rt.id]

  tags = {
    Name    = "S3Endpoint"
    Project = "DocuFlow"
  }
}

resource "aws_security_group" "endpoint_sg" {
  name        = "StepFunctionsEndpointSG"
  description = "Security group for Step Functions interface endpoint"
  vpc_id      = aws_vpc.docuflow-vpc.id

  # Allow HTTPS for AWS service communication
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "EndpointSG"
    Project = "DocuFlow"
  }
}

resource "aws_vpc_endpoint" "stepfunctions" {
  vpc_id              = aws_vpc.docuflow-vpc.id
  service_name        = "com.amazonaws.us-east-1.states"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    aws_subnet.private-subnet-1.id,
    aws_subnet.private-subnet-2.id
  ]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name    = "StepFunctionsEndpoint"
    Project = "DocuFlow"
  }
}


output "vpc_id" {
  value = aws_vpc.docuflow-vpc.id
}

output "private_subnet_ids" {
    value = [
        aws_subnet.private-subnet-1.id,
        aws_subnet.private-subnet-2.id
    ]
}

output "lambda_security_group_id" {
    value = aws_security_group.lambda-sg.id 
}