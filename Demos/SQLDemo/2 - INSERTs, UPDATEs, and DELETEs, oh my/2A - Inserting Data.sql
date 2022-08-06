-- Inserting Data

-- Insert with column list and without period columns
INSERT INTO Department (DepartmentId,
                        DepartmentName,
                        ManagerId,
                        ParentDepartmentId)
                VALUES (10,
                        'Marketing',
                        101,
                        1);

-- Insert with column list with period columns
INSERT INTO Department (DepartmentId,
                        DepartmentName,
                        ManagerId,
                        ParentDepartmentId,
                        ValidFrom,
                        ValidTo)
                VALUES (11,
                        'Sales',
                        101,
						1,
                        DEFAULT,
                        DEFAULT);

-- Insert without column list and DEFAULT values for period columns
INSERT INTO Department VALUES (12, 'Production', 101, 1, DEFAULT, DEFAULT);

INSERT INTO CompanyLocation VALUES ('Headquarters', 'New York')



























-- Insert without column list and hidden period columns
INSERT INTO CompanyLocation VALUES ('Headquarters', 'Grand Rapids, MI')