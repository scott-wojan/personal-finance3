import { createStyles, Table, Title } from "@mantine/core";
import axios from "axios";
import { CategoriesSelect } from "components/categories/CategoriesSelect";

import { groupBy } from "formatting";

import { useApi } from "hooks/useApi";

// @ts-ignore
import React, { Fragment, useEffect, useRef, useState } from "react";
import { SubCategoriesSelect } from "./SubCategoriesSelect";


export default function UserCategories() {
  const useStyles = createStyles((theme) => ({
    table: {
      width: "auto",
      td: {
        paddingTop: "2px !important",
        paddingBottom: "2px !important",
        borderBottom: "0 !important",
      },
    },
    category: {
      fontWeight: 600,
    },
    subcategory: {
      paddingLeft: `${theme.spacing.lg}px !important`,
    },
  }));

  const { classes, cx } = useStyles();

  // @ts-ignore
  const { isLoading, error, data } = useApi({
    url: "usercategories",
  });

  // useEffect(() => {
  //   if(data)
  //   console.log("data", data);
  //   console.log("grouped", groupBy(data,"user_category"));
  // }, [data]);

  if (error) {
    // @ts-ignore
    return <div>ERROR... {error.message}</div>;
  }

  return (
    <>
      <Title order={3}>Category Management</Title>
      <Table  className={cx(classes.table)}>
        <thead>
          <tr>
            <th>Category</th>
          </tr>
        </thead>
        <tbody>
        {data &&
            Object.entries(groupBy(data,"user_category")).map(
              ([key, value]) => {
                return (
                <Fragment key={key}>
                  <tr>
                    <td className={cx(classes.category)}>{key}</td>                   
                  </tr>
                  {value.map((subcategory) => {
                      console.log("subcategory", subcategory)
                      return (
                      <tr key={subcategory.user_subcategory}>
                        <td className={cx(classes.subcategory)}>
                        {subcategory.user_subcategory}
                        </td>
                    </tr>
                      )
                    })}            
                </Fragment>
                )
              }
            )
        }
        </tbody>
      </Table>  
    </>    
  );
}

function CategorySubCategories({ categoryId, category, subcategory }) {
  const [selectedCategory, setSelectedCategory] = useState(category);
  const [selectedSubCategory, setSelectedSubCategory] = useState(subcategory);
  const subcategoryDropdownRef = useRef();
  const onCategorySelected = (value) => {
    if (value === null) return;
    setSelectedCategory(value);
    setSelectedSubCategory(null);
    setTimeout(() => {
      // @ts-ignore
      subcategoryDropdownRef?.current?.value = null;
      // @ts-ignore
      subcategoryDropdownRef?.current?.focus();
    }, 100);
  };

  const onSubCategorySelected = (value) => {
    setSelectedSubCategory(value);
    if(selectedCategory && value){
      axios.post("api/usercategories/update",{
        categoryId,
        category:selectedCategory,
        subcategory:value
      })
      // console.log(`update user category ${categoryId} to ${selectedCategory} and ${value}`)
    }
  }

  return (
    <>
      <CategoriesSelect
        value={selectedCategory}
        onChange={onCategorySelected}
      />
      <SubCategoriesSelect
        ref={subcategoryDropdownRef}
        // @ts-ignore
        value={selectedSubCategory}
        category={selectedCategory}
        onChange={onSubCategorySelected}
      />
    </>
  );
}
